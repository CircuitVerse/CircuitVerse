# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

require "pg_search"
require "custom_optional_target/web_push"
class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged history]
  self.ignored_columns = ["data"]

  validates :name, length: { minimum: 1 }
  validates :slug, uniqueness: true

  belongs_to :author, class_name: "User"
  has_many :forks, class_name: "Project", foreign_key: "forked_project_id", dependent: :nullify
  belongs_to :forked_project, class_name: "Project", optional: true
  has_many :stars, dependent: :destroy
  has_many :user_ratings, through: :stars, dependent: :destroy, source: "user"
  belongs_to :assignment, optional: true

  has_many :collaborations, dependent: :destroy
  has_many :collaborators, source: "user", through: :collaborations
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  mount_uploader :image_preview, ImagePreviewUploader
  has_one :featured_circuit
  has_one :grade, dependent: :destroy
  has_one :project_datum, dependent: :destroy

  scope :public_and_not_forked,
        -> { where(project_access_type: "Public", forked_project_id: nil) }

  scope :open, -> { where(project_access_type: "Public") }

  scope :by, ->(author_id) { where(author_id: author_id) }

  include PgSearch::Model
  accepts_nested_attributes_for :project_datum
  pg_search_scope :text_search, against: %i[name description], associated_against: {
    tags: :name
  }, using: {
    tsearch: {
      dictionary: "english", tsvector_column: "searchable"
    }
  }

  trigger.before(:insert, :update) do
    "tsvector_update_trigger(
        searchable, 'pg_catalog.english', description, name
      );"
  end

  searchable do
    text :name

    text :description

    text :author do
      author.name
    end

    text :tags do
      tags.map(&:name)
    end
  end

  after_update :check_and_remove_featured

  self.per_page = 6

  acts_as_commontable
  # after_commit :send_mail, on: :create

  def increase_views(user)
    increment!(:view) if user.nil? || (user.id != author_id)
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
    forked_project.image_preview = image_preview
    forked_project.update!(
      view: 1, author_id: user.id, forked_project_id: id, name: name
    )
    forked_project
  end

  def send_mail
    if forked_project_id.nil?
      UserMailer.new_project_email(author, self).deliver_later if project_submission == false
    elsif project_submission == false
      UserMailer.forked_project_email(author, forked_project, self).deliver_later
    end
  end

  acts_as_notifiable :users,
                     # Notification targets as :targets is a necessary option
                     targets: lambda { |project, _key|
                       [project.forked_project.author]
                     },
                     notifier: :author,
                     printable_name: lambda { |project|
                       "forked your project \"#{project.name}\""
                     },
                     notifiable_path: :project_notifiable_path,
                     optional_targets: {
                       CustomOptionalTarget::WebPush => {}
                     }

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
    self.tags = names.split(",").map(&:strip).uniq.map do |n|
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

  private

    def check_validity
      if (project_access_type != "Private") && !assignment_id.nil?
        errors.add(:project_access_type, "Assignment has to be private")
      end
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
      if saved_change_to_project_access_type? && saved_changes["project_access_type"][1] != "Public"
        FeaturedCircuit.find_by(project_id: id)&.destroy
      end
    end

    def should_generate_new_friendly_id?
      # FIXME: Remove extra query once production data is resolved
      name_changed? || Project.where(slug: slug).count > 1
    end
end
# rubocop:enable Metrics/ClassLength
