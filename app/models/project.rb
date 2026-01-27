# frozen_string_literal: true

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
  has_many :tags, -> { where.not(name: "") }, through: :taggings
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
  pg_search_scope :text_search, against: %i[name description], using: {
    tsearch: {
      dictionary: "english", tsvector_column: "searchable"
    }
  }

  after_update :check_and_remove_featured

  before_destroy :purge_circuit_preview

  self.per_page = 9

  acts_as_commontable
  # after_commit :send_mail, on: :create

  def increase_views(user)
    return if user.present? && user.id == author_id
    begin
      update_column(:view, view + 1)
    rescue ActiveRecord::StatementInvalid => e
      # If update fails due to statement timeout, silently continue
      # as view count is not critical to the core functionality
      Rails.logger.warn("Failed to increment project views for project #{id}: #{e.message}")
    end
  end

  # returns true if starred, false if unstarred
  def toggle_star(user)
    begin
      star = Star.find_by(user_id: user.id, project_id: id)
      if star.nil?
        begin
          @star = Star.create!(user_id: user.id, project_id: id)
          true
        rescue ActiveRecord::RecordNotUnique
          # Handle race condition where star was created between find and create
          false
        end
      else
        star.destroy!
        false
      end
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.warn("Failed to toggle star for project #{id}: #{e.message}")
      false
    end
  end

  def fork(user)
    forked_project = dup
    forked_project.build_project_datum.data = project_datum&.data
    
    # Only attach circuit preview if it exists, to avoid timeouts with large files
    if circuit_preview.attached?
      begin
        forked_project.circuit_preview.attach(circuit_preview.blob)
      rescue StandardError => e
        Rails.logger.warn("Failed to copy circuit preview for forked project: #{e.message}")
        # Continue without the preview rather than fail the entire fork operation
      end
    end
    
    forked_project.image_preview = image_preview
    forked_project.update!(
      view: 1, author_id: user.id, forked_project_id: id, name: name
    )
    
    # Refresh to ensure we have the latest data
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
    self.tags = names.split(",").map(&:strip).uniq.compact_blank.map do |n|
      Tag.where(name: n.strip).first_or_create!
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
      return unless (project_access_type != "Private") && !assignment_id.nil?

      errors.add(:project_access_type, "Assignment has to be private")
    end

    def clean_description
      profanity_filter = LanguageFilter::Filter.new matchlist: :profanity
      return nil unless profanity_filter.match? description

      errors.add(
        :description,
        "contains inappropriate language: #{profanity_filter.matched(description).join(', ')}"
      )
    end

    def check_and_remove_featured
      return unless saved_change_to_project_access_type? && saved_changes["project_access_type"][1] != "Public"

      FeaturedCircuit.find_by(project_id: id)&.destroy
    end

    def should_generate_new_friendly_id?
      # FIXME: Remove extra query once production data is resolved
      name_changed? || Project.where(slug: slug).many?
    end

    def purge_circuit_preview
      circuit_preview.purge if circuit_preview.attached?
    end
end
