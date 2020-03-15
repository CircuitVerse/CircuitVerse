unless ENV['AN_TEST_DB'] == 'mongodb'
  class Article < ActiveRecord::Base
    belongs_to :user
    has_many :comments, dependent: :destroy
    has_many :commented_users, through: :comments, source: :user
    validates :user, presence: true

    acts_as_notifiable :users,
      targets: ->(article) { User.all.to_a - [article.user] },
      notifier: :user, email_allowed: true, action_cable_allowed: true,
      printable_name: ->(article) { "new article \"#{article.title}\"" },
      dependent_notifications: :delete_all
    acts_as_notification_group printable_name: ->(article) { "article \"#{article.title}\"" }

    def author?(user)
      self.user == user
    end
  end
else
  require 'mongoid'
  class Article
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification

    belongs_to :user
    has_many :comments, dependent: :destroy
    validates :user, presence: true

    field :title, type: String
    field :body,  type: String

    include ActivityNotification::Models
    acts_as_notifiable :users,
      targets: ->(article) { User.all.to_a - [article.user] },
      notifier: :user, email_allowed: true, action_cable_allowed: true,
      printable_name: ->(article) { "new article \"#{article.title}\"" },
      dependent_notifications: :delete_all
    acts_as_notification_group printable_name: ->(article) { "article \"#{article.title}\"" }

    def commented_users
      User.where(:id.in => comments.pluck(:user_id))
    end

    def author?(user)
      self.user == user
    end
  end
end
