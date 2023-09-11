# frozen_string_literal: true

class User < ApplicationRecord
  mailkick_user
  require "pg_search"
  include SimpleDiscussion::ForumUser
  validates :email, undisposable: { message: "Sorry, but we do not accept your mail provider." }
  self.ignored_columns += %w[profile_picture_file_name profile_picture_content_type profile_picture_file_size profile_picture_updated_at]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :projects, foreign_key: "author_id", dependent: :destroy
  has_many :stars
  has_many :rated_projects, through: :stars, dependent: :destroy, source: "project"
  has_many :groups_owned, class_name: "Group", foreign_key: "primary_mentor_id", dependent: :destroy
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :validatable, :omniauthable, :saml_authenticatable, omniauth_providers: %i[google_oauth2 facebook github gitlab]

  # has_many :assignments, foreign_key: 'mentor_id', dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :grades
  acts_as_commontator

  has_many :collaborations, dependent: :destroy
  has_many :collaborated_projects, source: "project", through: :collaborations

  has_many :pending_invitations, foreign_key: :email, primary_key: :email

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

  pg_search_scope :text_search, against: %i[name educational_institute country]

  searchable do
    text :name
    text :educational_institute
    text :country
  end

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

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

    def send_welcome_mail
      UserMailer.welcome_email(self).deliver_later
    end

    def purge_profile_picture
      profile_picture.purge if profile_picture.attached?
    end
end
