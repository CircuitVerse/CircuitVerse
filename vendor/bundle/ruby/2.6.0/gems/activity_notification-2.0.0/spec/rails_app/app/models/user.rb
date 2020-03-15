unless ENV['AN_TEST_DB'] == 'mongodb'
  class User < ActiveRecord::Base
    devise :database_authenticatable, :registerable, :confirmable
    validates :email, presence: true
    has_many :articles, dependent: :destroy
    has_one :admin, dependent: :destroy

    acts_as_target email: :email, email_allowed: :confirmed_at, batch_email_allowed: :confirmed_at,
                   subscription_allowed: true, printable_name: :name,
                   action_cable_allowed: true, action_cable_with_devise: true
    acts_as_notifier printable_name: :name

    def admin?
      admin.present?
    end
  end
else
  require 'mongoid'
  class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification

    devise :database_authenticatable, :registerable, :confirmable
    has_many :articles, dependent: :destroy
    has_one :admin, dependent: :destroy
    validates :email, presence: true
    # Devise
    ## Database authenticatable
    field :email,                type: String, default: ""
    field :encrypted_password,   type: String, default: ""
    ## Confirmable
    field :confirmation_token,   type: String
    field :confirmed_at,         type: Time
    field :confirmation_sent_at, type: Time
    # Apps
    field :name,                 type: String

    include ActivityNotification::Models
    acts_as_target email: :email, email_allowed: :confirmed_at, batch_email_allowed: :confirmed_at,
                   subscription_allowed: true, printable_name: :name,
                   action_cable_allowed: true, action_cable_with_devise: true
acts_as_notifier printable_name: :name

    def admin?
      admin.present?
    end
  end
end
