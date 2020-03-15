require 'activity_notification/roles/acts_as_common'
require 'activity_notification/roles/acts_as_target'
require 'activity_notification/roles/acts_as_notifiable'
require 'activity_notification/roles/acts_as_notifier'
require 'activity_notification/roles/acts_as_group'

module ActivityNotification
  module Models
    extend ActiveSupport::Concern
    included do
      include ActivityNotification::ActsAsCommon
      include ActivityNotification::ActsAsTarget
      include ActivityNotification::ActsAsNotifiable
      include ActivityNotification::ActsAsNotifier
      include ActivityNotification::ActsAsGroup
    end
  end
end

ActiveRecord::Base.class_eval { include ActivityNotification::Models } if defined?(ActiveRecord::Base)
