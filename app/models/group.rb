# frozen_string_literal: true

class Group < ApplicationRecord
  has_secure_token :group_token
  validates :name, length: { minimum: 1 }, presence: true
  belongs_to :primary_mentor, class_name: "User"
  belongs_to :organization, optional: true
  belongs_to :parent_group, class_name: "Group", optional: true
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members
  has_many :subgroups, class_name: "Group", foreign_key: :parent_group_id,
                       inverse_of: :parent_group, dependent: :destroy

  belongs_to :team_project, class_name: "Project", optional: true
  has_many :assignments, dependent: :destroy
  has_many :pending_invitations, dependent: :destroy

  before_validation :inherit_primary_mentor_from_parent, on: :create, if: :subgroup?
  validates :name, uniqueness: { scope: :parent_group_id, case_sensitive: false }, if: :subgroup?
  validate :parent_group_must_be_top_level, if: :subgroup?
  validate :team_project_author_must_be_member, if: :team_project_id?

  after_commit :send_creation_mail, on: :create, unless: :subgroup?
  scope :with_valid_token, -> { where(token_expires_at: Time.zone.now..) }
  scope :top_level, -> { where(parent_group_id: nil) }
  TOKEN_DURATION = 12.days

  def subgroup?
    parent_group_id.present?
  end

  def share_team_project
    return unless team_project

    group_members.where.not(user_id: team_project.author_id).pluck(:user_id).each do |user_id|
      Collaboration.find_or_create_by!(project_id: team_project_id, user_id: user_id)
    end
  end

  def send_creation_mail
    GroupMailer.new_group_email(primary_mentor, self).deliver_later
  end

  def has_valid_token?
    token_expires_at.present? && token_expires_at > Time.zone.now
  end

  def add_member_to_organization(user)
    return if organization.blank?

    organization.organization_members.find_or_create_by!(user: user) do |member|
      member.role = :member
    end
  end

  def reset_group_token
    transaction do
      regenerate_group_token
      update(token_expires_at: Time.zone.now + TOKEN_DURATION)
    end
  end

  private

    def inherit_primary_mentor_from_parent
      self.primary_mentor = parent_group.primary_mentor if parent_group
    end

    def team_project_author_must_be_member
      return if subgroup? && group_members.exists?(user_id: team_project.author_id)

      errors.add(:team_project, "must belong to a member of the subgroup")
    end

    def parent_group_must_be_top_level
      errors.add(:parent_group, "cannot itself be a subgroup") if parent_group&.subgroup?
    end
end
