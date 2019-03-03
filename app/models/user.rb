class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :projects,  :foreign_key => 'author_id' , dependent: :destroy
  has_many :stars
  has_many :rated_projects,   through: :stars , dependent: :destroy , source: 'project'
  has_many :groups_mentored, class_name: 'Group',  :foreign_key => 'mentor_id' , dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:google_oauth2,:facebook]

  # has_many :assignments, foreign_key: 'mentor_id', dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  acts_as_commontator

  has_many :collaborations, dependent: :destroy
  has_many :collaborated_projects, source: 'project', through: :collaborations

  after_commit :send_mail ,  on: :create
  after_commit :check_group_invites, on: :create

  has_attached_file :profile_picture, styles: { medium: "205X240#", thumb: "100x100>" }, default_url: ":style/Default.jpg"
  validates_attachment_content_type :profile_picture, content_type: /\Aimage\/.*\z/

  def send_mail
    UserMailer.welcome_email(self).deliver_later
  end

  def country_name
    country = ISO3166::Country[self.country]
    country.translations[I18n.locale.to_s] || country.name
  end

  def check_group_invites
    PendingInvitation.where(email:self.email).each do |invitation|
      GroupMember.where(group_id:invitation.group.id,user_id:self.id).first_or_create
      invitation.destroy
    end
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first
    # Uncomment the section below if you want users to be created if they don't exist
    unless user
        user = User.create(name: data['name'],
           email: data['email'],
           password: Devise.friendly_token[0,20],
           provider: access_token.provider,
           uid: access_token.uid
        )
    end
    user
  end
end
