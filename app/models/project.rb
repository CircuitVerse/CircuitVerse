# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

require "pg_search"

class Project < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: %i[slugged history]
  self.ignored_columns += %w[data searchable]

  validates :name, length: { minimum: 1 }
  validates :slug, uniqueness: true

  belongs_to :author, class_name: "User", counter_cache: true
  has_many :forks, class_name: "Project", foreign_key: "forked_project_id", dependent: :nullify
  belongs_to :forked_project, class_name: "Project", optional: true
  has_many :stars, dependent: :destroy
  has_many :user_ratings, through: :stars, dependent: :destroy, source: "user"
  belongs_to :assignment, optional: true

  has_noticed_notifications model_name: "NoticedNotification"
  has_many :noticed_notifications, through: :author
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, source: "user", through: :collaborations
  has_many :taggings, dependent: :destroy
  # Exclude NULL, empty or whitespace-only tag names to avoid returning invalid tags
  has_many :tags, -> { where("name IS NOT NULL AND TRIM(BOTH FROM name) <> ''") }, through: :taggings
  mount_uploader :image_preview, ImagePreviewUploader
  has_one_attached :circuit_preview
  has_one :featured_circuit
  has_one :grade, dependent: :destroy
  has_one :project_datum, dependent: :destroy
  has_many :notifications, as: :notifiable
  has_one :contest_winner, dependent: :destroy
  has_many :submissions, dependent: :destroy

  scope :public_and_not_forked,
        -> { where(project_access_type: "Public", forked_project_id: nil) }
  scope :open, -> { where(project_access_type: "Public") }
  scope :by, ->(author_id) { where(author_id: author_id) }

  include PgSearch::Model

  accepts_nested_attributes_for :project_datum
  pg_search_scope :text_search,
                  against: %i[name description],
                  using: {
                    tsearch: {
                      dictionary: "english",
                      tsvector_column: "searchable"
                    }
                  }

  after_update :check_and_remove_featured
  before_destroy :purge_circuit_preview

  self.per_page = 9

  acts_as_commontable
  # after_commit :send_mail, on: :create

  def increase_views(user)
    increment!(:view) if user.nil? || user.id != author_id
  end

  # returns true if starred, false if unstarred
  def toggle_star(user)
    star = Star.find_by(user_id: user.id, project_id: id)
    if star.nil?
      @star = Star.create!(user_id: user.id, project_id: id)
      true
    else
      star.destroy!
      false
    end
  end

  def fork(user)
    forked_project = dup
    forked_project.build_project_datum.data = project_datum&.data
    forked_project.circuit_preview.attach(circuit_preview.blob)
    forked_project.image_preview = image_preview
    forked_project.update!(
      view: 1,
      author_id: user.id,
      forked_project_id: id,
      name: name
    )

    @project = Project.find(id)
    if @project.author != user # rubocop:disable Style/IfUnlessModifier
      ForkNotification.with(user: user, project: @project).deliver_later(@project.author)
    end

    forked_project
  end

  def send_mail
    if forked_project_id.nil?
      UserMailer.new_project_email(author, self).deliver_later if project_submission == false
    elsif project_submission == false
      UserMailer.forked_project_email(author, forked_project, self).deliver_later
    end
  end

  def project_notifiable_path
    user_project_path(forked_project.author, forked_project)
  end

  def self.tagged_with(name)
    Tag.find_by!(name: name).projects
  end

  def tag_list
    tags.map(&:name).join(", ")
  end

  def tag_list=(names)
    self.tags = []
    return if names.nil?

    sanitized = sanitize_tag_input(names.to_s)

    self.tags = sanitized
                .split(",")
                .map(&:strip)
                .uniq(&:downcase)
                .filter_map do |name|
                  next if name.blank?

                  find_or_create_tag_case_insensitive(name)
                end
  end

  def public?
    project_access_type == "Public"
  end

  def featured?
    project_access_type == "Public" && FeaturedCircuit.exists?(project_id: id)
  end

  validate :check_validity
  validate :clean_description

  def sim_version
    raw_data = project_datum&.data
    parsed_data = raw_data.present? ? JSON.parse(raw_data) : {}
    parsed_data["simulatorVersion"] || "legacy"
  end

  def uses_vue_simulator?
    %w[v0 v1].include?(sim_version)
  end

  private

    def check_validity
      return unless project_access_type != "Private" && !assignment_id.nil?

      errors.add(:project_access_type, "Assignment has to be private")
    end

    def clean_description
      profanity_filter = LanguageFilter::Filter.new matchlist: :profanity
      return unless profanity_filter.match?(description)

      errors.add(
        :description,
        "contains inappropriate language: #{profanity_filter.matched(description).join(', ')}"
      )
    end

    def check_and_remove_featured
      return unless saved_change_to_project_access_type? &&
                    saved_changes["project_access_type"][1] != "Public"

      FeaturedCircuit.find_by(project_id: id)&.destroy
    end

    def should_generate_new_friendly_id?
      # FIXME: Remove extra query once production data is resolved
      name_changed? || Project.where(slug: slug).many?
    end

    def purge_circuit_preview
      circuit_preview.purge if circuit_preview.attached?
    end

    # Sanitize the provided tag input and warn if any replacements occurred
    def sanitize_tag_input(original_input)
      sanitized = original_input
                  .encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
                  .delete("\u0000")

      if sanitized != original_input
        Rails.logger.warn(
          "Project#tag_list=: sanitization modified tag input for project_id=#{id || 'unsaved'}; " \
          "original=#{original_input.inspect}; sanitized=#{sanitized.inspect}"
        )
      end

      sanitized
    end

    # Case-insensitive find or create for a tag. Returns the tag or nil on failure.
    def find_or_create_tag_case_insensitive(name)
      # Try to find case-insensitively first
      existing = Tag.where("LOWER(name) = ?", name.downcase).first
      return existing if existing

      # If not found, try to create. Handle races where another process
      # creates the tag concurrently by rescuing ActiveRecord::RecordNotUnique
      begin
        Tag.create!(name: name)
      rescue ActiveRecord::RecordNotUnique
        # Likely a race: re-query and return the existing record if present
        Tag.where("LOWER(name) = ?", name.downcase).first
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
        Rails.logger.warn(
          "Project#tag_list=: failed to create tag #{name.inspect} for project_id=#{id || 'unsaved'}: " \
          "#{e.class}: #{e.message}"
        )
        nil
      end
    end
end

# rubocop:enable Metrics/ClassLength
