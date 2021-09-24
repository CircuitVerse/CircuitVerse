module UserModel
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :confirmable
    include DeviseTokenAuth::Concerns::User
    validates :email, presence: true
    has_one :admin, dependent: :destroy
    has_many :articles, dependent: :destroy

    acts_as_target email: :email,
      email_allowed: :confirmed_at, batch_email_allowed: :confirmed_at,
      subscription_allowed: true,
      action_cable_allowed: true, action_cable_with_devise: true,
      printable_name: :name

    acts_as_notifier printable_name: :name
  end

  def admin?
    admin.present?
  end

  def as_json(_options = {})
    options = _options.deep_dup
    options[:include] = (options[:include] || {}).merge(admin: { methods: [:printable_target_name, :notification_action_cable_allowed?, :notification_action_cable_with_devise?] })
    options[:methods] = (options[:methods] || []).push(:printable_target_name, :notification_action_cable_allowed?, :notification_action_cable_with_devise?)
    super(options)
  end
end

unless ENV['AN_TEST_DB'] == 'mongodb'
  class User < ActiveRecord::Base
    include UserModel
    default_scope { order(:id) }
  end
else
  require 'mongoid'
  require 'mongoid-locker'
  class User
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Locker
    include GlobalID::Identification

    # Devise
    ## Database authenticatable
    field :email,                type: String, default: ""
    field :encrypted_password,   type: String, default: ""
    ## Confirmable
    field :confirmation_token,   type: String
    field :confirmed_at,         type: Time
    field :confirmation_sent_at, type: Time
    ## Required
    field :provider,             type: String, default: "email"
    field :uid,                  type: String, default: ""
    ## Tokens
    field :tokens,               type: Hash,   default: {}
    # Apps
    field :name,                 type: String

    include ActivityNotification::Models
    include UserModel

    # To avoid Devise Token Auth issue
    # https://github.com/lynndylanhurley/devise_token_auth/issues/1335
    if Rails::VERSION::MAJOR == 6
      def saved_change_to_attribute?(attr_name, **options)
        true
      end
    end
  end
end
