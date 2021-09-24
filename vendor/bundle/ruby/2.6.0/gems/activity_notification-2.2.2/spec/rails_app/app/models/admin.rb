module AdminModel
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    validates :user, presence: true

    acts_as_notification_target email_allowed: false,
      subscription_allowed: true,
      action_cable_allowed: true, action_cable_with_devise: true,
      devise_resource: :user,
      current_devise_target: ->(current_user) { current_user.admin },
      printable_name: ->(admin) { "#{admin.user.name} (admin)" }
  end
end

unless ENV['AN_TEST_DB'] == 'mongodb'
  class Admin < ActiveRecord::Base
    include AdminModel
    default_scope { order(:id) }
  end
else
  require 'mongoid'
  class Admin
    include Mongoid::Document
    include Mongoid::Timestamps
    include GlobalID::Identification

    field :phone_number,   type: String
    field :slack_username, type: String

    include ActivityNotification::Models
    include AdminModel
  end
end
