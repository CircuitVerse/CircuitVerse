# frozen_string_literal: true

class User < ApplicationRecord
  mailkick_user
  require "pg_search"
  include SimpleDiscussion::ForumUser

  validates :email, undisposable: { message: "Sorry, but we do not accept your mail provider." }
  self.ignored_columns += %w[profile_picture_file_name profile_picture_content_type profile_picture_file_size
                             profile_picture_updated_at]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :projects, foreign_key: "author_id", dependent: :destroy
  has_many :stars
  has_many :votes, class_name: "ActsAsVotable::Vote", as: :voter, dependent: :destroy
  has_many :rated_projects, through: :stars, dependent: :destroy, source: "project"
  has_many :groups_owned, class_name: "Group", foreign_key: "primary_mentor_id", dependent: :destroy
  devise :confirmable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable, :omniauthable, :saml_authenticatable,
         omniauth_providers: %i[google_oauth2 facebook github gitlab]

  # has_many :assignments, foreign_key: 'mentor_id', dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :grades
  acts_as_commontator
  has_many :submissions, dependent: :destroy
  has_many :collaborations, dependent: :destroy
  has_many :collaborated_projects, source: "project", through: :collaborations

  has_many :pending_invitations, foreign_key: :email, primary_key: :email

  # Ban management with full audit trail
  has_many :user_bans, dependent: :destroy
  has_many :imposed_bans, class_name: "UserBan", foreign_key: "admin_id", dependent: :nullify

  # Report associations
  has_many :reports_filed, class_name: "Report", foreign_key: "reporter_id", dependent: :destroy
  has_many :reports_received, class_name: "Report", foreign_key: "reported_user_id", dependent: :destroy

  # noticed configuration
  has_many :noticed_notifications, as: :recipient, dependent: :destroy

  # Multiple push_subscriptions over many devices
  has_many :push_subscriptions, dependent: :destroy

  before_destroy :purge_profile_picture
  after_commit :send_welcome_mail, on: :create
  after_commit :create_members_from_invitations, on: :create

  has_one_attached :profile_picture
  before_validation { profile_picture.purge if remove_picture == "1" }

  attr_accessor :remove_picture

  validates :name, presence: true, format: { without: /\A["!@#$%^&]*\z/,
                                             message: "can only contain letters and spaces" }

  validates :email, presence: true, format: /\A[^@,\s]+@[^@,\s]+\.[^@,\s]+\z/

  scope :subscribed, -> { where(subscribed: true) }

  include PgSearch::Model

  pg_search_scope :text_search, against: %i[name educational_institute],
                                using: { tsearch: { dictionary: "english", tsvector_column: "searchable" } }

  scope :banned, -> { where(banned: true) }
  scope :active_users, -> { where(banned: false) }

  def create_members_from_invitations
    pending_invitations.reload.each do |invitation|
      GroupMember.where(group_id: invitation.group.id, user_id: id).first_or_create
      invitation.destroy
    end
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data["email"]).first
    name = data["name"] || data["nickname"]
    # Uncomment the section below if you want users to be created if they don't exist
    user ||= User.create(name: name,
                         email: data["email"],
                         password: Devise.friendly_token[0, 20],
                         provider: access_token.provider,
                         confirmed_at: Time.zone.now,
                         uid: access_token.uid)
    user
  end

  def self.from_oauth(oauth_user, provider)
    User.create(
      name: oauth_user["name"],
      email: oauth_user["email"],
      password: Devise.friendly_token[0, 20],
      provider: provider,
      uid: oauth_user["id"] || oauth_user["sub"]
    )
  end

  def flipper_id
    "User:#{id}"
  end

  def moderator?
    admin?
  end

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

  def votes_for_contest(contest)
    SubmissionVote.where(user_id: id, contest_id: contest).count
  end

  def banned?
    banned == true
  end

  def ban!(admin:, reason:, report: nil)
    return false if self == admin # Cannot self-ban
    return false if banned? # Already banned

    transaction do
      user_bans.create!(
        admin: admin,
        reason: reason,
        report: report
      )
      update!(banned: true)
      invalidate_all_sessions!
    end
    true
  rescue StandardError => e
    Rails.logger.error("Failed to ban user #{id}: #{e.message}")
    false
  end

  def unban!(admin:)
    transaction do
      active_ban = user_bans.active.last
      if active_ban
        active_ban.lift!(lifted_by: admin)
      else
        Rails.logger.warn("No active ban found for user #{id}, clearing banned flag only")
      end
      update!(banned: false)
    end
    true
  rescue StandardError => e
    Rails.logger.error("Failed to unban user #{id}: #{e.message}")
    false
  end

  def ban_history
    user_bans.sort_by(&:created_at).reverse
  end

  # Override Devise method to prevent banned users from signing in
  def active_for_authentication?
    super && !banned?
  end

  # Custom message for banned users
  def inactive_message
    banned? ? :banned : super
  end

  private

    def send_welcome_mail
      UserMailer.welcome_email(self).deliver_later
    end

    def purge_profile_picture
      profile_picture.purge if profile_picture.attached?
    end

    def invalidate_all_sessions!
      # Invalidate sessions by resetting Devise's rememberable token
      # This forces re-authentication on next request
      # Note: This is a best-effort operation - failure shouldn't block the ban
      #
      # TODO: Full session invalidation would also need to:
      # - Invalidate JWT/API tokens (requires token blacklist or versioning)
      # - Force logout existing browser sessions (requires session store integration)
      return unless respond_to?(:remember_created_at)

      # Reset remember token to invalidate "remember me" sessions
      update!(remember_created_at: nil) if remember_created_at.present?
    rescue StandardError => e
      # Silently ignore session invalidation errors - ban should still proceed
      Rails.logger.warn("Session invalidation failed for user #{id}: #{e.message}")
    end
end
