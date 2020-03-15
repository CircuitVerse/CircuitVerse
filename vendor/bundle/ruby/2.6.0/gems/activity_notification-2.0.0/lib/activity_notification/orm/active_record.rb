module ActivityNotification
  module Association
    extend ActiveSupport::Concern

    class_methods do
      # Defines has_many association with ActivityNotification models.
      # @return [ActiveRecord_AssociationRelation<Object>] Database query of associated model instances
      def has_many_records(name, options = {})
        has_many name, options
      end
    end
  end
end

require_relative 'active_record/notification.rb'
require_relative 'active_record/subscription.rb'
