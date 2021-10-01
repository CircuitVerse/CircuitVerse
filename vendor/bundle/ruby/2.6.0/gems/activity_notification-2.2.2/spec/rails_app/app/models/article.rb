module ArticleModel
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    has_many :comments, dependent: :destroy
    validates :user, presence: true

    acts_as_notifiable :users,
      targets: ->(article) { User.all.to_a - [article.user] },
      notifier: :user, email_allowed: true,
      action_cable_allowed: true, action_cable_api_allowed: true,
      printable_name: ->(article) { "new article \"#{article.title}\"" },
      dependent_notifications: :delete_all

    acts_as_notifiable :admins,
      targets: ->(article) { Admin.all.to_a },
      notifier: :user,
      action_cable_allowed: true, action_cable_api_allowed: true,
      tracked: Rails.env.test? ? {only: []} : { only: [:create, :update], action_cable_rendering: { fallback: :default } },
      printable_name: ->(article) { "new article \"#{article.title}\"" },
      dependent_notifications: :delete_all

    acts_as_notification_group printable_name: ->(article) { "article \"#{article.title}\"" }
  end

  def author?(user)
    self.user == user
  end
end

unless ENV['AN_TEST_DB'] == 'mongodb'
  class Article < ActiveRecord::Base
    include ArticleModel
    has_many :commented_users, through: :comments, source: :user
  end
else
  require 'mongoid'
  class Article
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification

    field :title, type: String
    field :body,  type: String

    include ActivityNotification::Models
    include ArticleModel

    def commented_users
      User.where(:id.in => comments.pluck(:user_id))
    end
  end
end
