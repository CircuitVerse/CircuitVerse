require 'rails'
require 'active_support'
require 'action_view'

module ActivityNotification
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Notification,     'activity_notification/models/notification'
  autoload :Subscription,     'activity_notification/models/subscription'
  autoload :Target,           'activity_notification/models/concerns/target'
  autoload :Subscriber,       'activity_notification/models/concerns/subscriber'
  autoload :Notifiable,       'activity_notification/models/concerns/notifiable'
  autoload :Notifier,         'activity_notification/models/concerns/notifier'
  autoload :Group,            'activity_notification/models/concerns/group'
  autoload :Common
  autoload :Config
  autoload :Renderable
  autoload :VERSION
  autoload :GEM_VERSION

  module Mailers
    autoload :Helpers,        'activity_notification/mailers/helpers'
  end

  # Returns configuration object of ActivityNotification.
  def self.config
    @config ||= ActivityNotification::Config.new
  end

  # Sets global configuration options for ActivityNotification.
  # All available options and their defaults are in the example below:
  # @example Initializer for Rails
  #   ActivityNotification.configure do |config|
  #     config.enabled            = true
  #     config.table_name         = "notifications"
  #     config.email_enabled      = false
  #     config.mailer_sender      = nil
  #     config.mailer             = 'ActivityNotification::Mailer'
  #     config.parent_mailer      = 'ActionMailer::Base'
  #     config.parent_controller  = 'ApplicationController'
  #     config.opened_index_limit = 10
  #   end
  def self.configure
    yield(config) if block_given?
    autoload :Association, "activity_notification/orm/#{ActivityNotification.config.orm}"
  end

  # Method used to choose which ORM to load
  # when ActivityNotification::Notification class or ActivityNotification::Subscription class
  # are being autoloaded
  def self.inherit_orm(model)
    orm = ActivityNotification.config.orm
    require "activity_notification/orm/#{orm}"
    "ActivityNotification::ORM::#{orm.to_s.classify}::#{model}".constantize
  end
end

# Load ActivityNotification helpers
require 'activity_notification/helpers/errors'
require 'activity_notification/helpers/polymorphic_helpers'
require 'activity_notification/helpers/view_helpers'
require 'activity_notification/controllers/common_controller'
require 'activity_notification/controllers/common_api_controller'
require 'activity_notification/controllers/store_controller'
require 'activity_notification/controllers/devise_authentication_controller'
require 'activity_notification/optional_targets/base'

# Load Swagger API references
require 'activity_notification/apis/swagger'
require 'activity_notification/models/concerns/swagger/notification_schema'
require 'activity_notification/models/concerns/swagger/subscription_schema'
require 'activity_notification/models/concerns/swagger/error_schema'
require 'activity_notification/controllers/concerns/swagger/notifications_parameters'
require 'activity_notification/controllers/concerns/swagger/subscriptions_parameters'
require 'activity_notification/controllers/concerns/swagger/error_responses'
require 'activity_notification/controllers/concerns/swagger/notifications_api'
require 'activity_notification/controllers/concerns/swagger/subscriptions_api'

# Load role for models
require 'activity_notification/models'

# Define Rails::Engine
require 'activity_notification/rails'
