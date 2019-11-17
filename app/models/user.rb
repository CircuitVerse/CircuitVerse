# frozen_string_literal: true

class User < ApplicationRecord
  require "pg_search"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :projects,  foreign_key: "author_id", dependent: :destroy
  has_many :stars
  has_many :rated_projects,   through: :stars, dependent: :destroy, source: "project"
  has_many :groups_mentored, class_name: "Group",  foreign_key: "mentor_id", dependent: :destroy
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
    :validatable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  # has_many :assignments, foreign_key: 'mentor_id', dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :grades
  acts_as_commontator

  has_many :collaborations, dependent: :destroy
  has_many :collaborated_projects, source: "project", through: :collaborations

  has_many :pending_invitations, foreign_key: :email, primary_key: :email

  after_commit :send_welcome_mail,  on: :create
  after_commit :create_members_from_invitations, on: :create

  has_attached_file :profile_picture, styles: { medium: "205X240#", thumb: "100x100>" }, default_url: ":style/Default.jpg"
  validates_attachment_content_type :profile_picture, content_type: /\Aimage\/.*\z/

  scope :subscribed, -> { where(subscribed: true) }

  include PgSearch::Model
  pg_search_scope :text_search, against: [:name, :educational_institute, :country]

  searchable do
    text :name
    text :educational_institute
    text :country
  end


  def create_members_from_invitations
    pending_invitations.reload.each do |invitation|
      GroupMember.where(group_id: invitation.group.id, user_id: self.id).first_or_create
      invitation.destroy
    end
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data["email"]).first
    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(name: data["name"],
         email: data["email"],
         password: Devise.friendly_token[0, 20],
         provider: access_token.provider,
         uid: access_token.uid
      )
    end
    user
  end

  private

    def send_welcome_mail
      UserMailer.welcome_email(self).deliver_later
    end
end
