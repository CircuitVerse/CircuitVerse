# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

#
# == Schema Information
#
# Table name: projects
#
#  id                   :bigint           not null, primary key
#  name                 :string
#  author_id            :bigint
#  forked_project_id    :bigint
#  project_access_type  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  assignment_id        :bigint
#  project_submission   :boolean          default(FALSE)
#  image_preview        :string
#  description          :text
#  view                 :bigint           default(1)
#  slug                 :string
#  searchable           :tsvector
#  lis_result_sourced_id :string
#
# Indexes
#
#  index_projects_on_assignment_id      (assignment_id)
#  index_projects_on_author_id           (author_id)
#  index_projects_on_forked_project_id   (forked_project_id)
#  index_projects_on_searchable          (searchable) USING gin
#  index_projects_on_slug_and_author_id  (slug,author_id) UNIQUE

require "pg_search"
class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged history]
  self.ignored_columns += ["data"]

  validates :name, length: { minimum: 1 }
  validates :slug, uniqueness: true

  belongs_to :author, class_name: "User"
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
  has_many :tags, through: :taggings
  mount_uploader :image_preview, ImagePreviewUploader
  has_one_attached :circuit_preview
  has_one :featured_circuit
  has_one :grade, dependent: :destroy
  has_one :project_datum, dependent: :destroy
  has_many :notifications, as: :notifiable

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

  before_destroy :purge_circuit_preview

  self.per_page = 6

  acts_as_commontable
  # after_commit :send_mail, on: :create

  # Increments the view count of a project if the user is not the author
  # @param [User] user
  # @return [void]
  def increase_views(user)
    increment!(:view) if user.nil? || (user.id != author_id)
  end

  # Toggle the star of a project for a user
  # @param [User] user
  # @return [Boolean] returns true if starred, false if unstarred
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

  # Fork a project
  # @param [User] user
  # @return [Project] returns the forked project
  def fork(user)
    forked_project = dup
    forked_project.build_project_datum.data = project_datum&.data
    forked_project.circuit_preview.attach(circuit_preview.blob)
    forked_project.image_preview = image_preview
    forked_project.update!(
      view: 1, author_id: user.id, forked_project_id: id, name: name
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

  # @param [String] name
  # @return [Array<Project>] returns a list of projects with the given tag
  def self.tagged_with(name)
    Tag.find_by!(name: name).projects
  end

  # @return [String] returns a list of tags separated by commas
  def tag_list
    tags.map(&:name).join(", ")
  end

  # @param [String] names
  # @return [void]
  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).uniq.map do |n|
      Tag.where(name: n.strip).first_or_create!
    end
  end

  # @return [Boolean] returns true if the project is public, false otherwise
  def public?
    project_access_type == "Public"
  end

  # @return [Boolean] returns true if the project is featured, false otherwise
  def featured?
    project_access_type == "Public" && FeaturedCircuit.exists?(project_id: id)
  end

  validate :check_validity
  validate :clean_description

  private

    # Validates that the project is not a public assignment
    # @return [void]
    def check_validity
      if (project_access_type != "Private") && !assignment_id.nil?
        errors.add(:project_access_type, "Assignment has to be private")
      end
    end

    # Validates that the project description does not contain inappropriate language
    def clean_description
      profanity_filter = LanguageFilter::Filter.new matchlist: :profanity
      return nil unless profanity_filter.match? description

      errors.add(
        :description,
        "contains inappropriate language: #{profanity_filter.matched(description).join(', ')}"
      )
    end

    # Removes the featured circuit if the project is no longer public
    def check_and_remove_featured
      if saved_change_to_project_access_type? && saved_changes["project_access_type"][1] != "Public"
        FeaturedCircuit.find_by(project_id: id)&.destroy
      end
    end

    # Generates a new slug if the name of the project has changed
    # @return [Boolean] returns true if the slug has changed, false otherwise
    def should_generate_new_friendly_id?
      # FIXME: Remove extra query once production data is resolved
      name_changed? || Project.where(slug: slug).count > 1
    end

    def purge_circuit_preview
      circuit_preview.purge if circuit_preview.attached?
    end
end
# rubocop:enable Metrics/ClassLength
