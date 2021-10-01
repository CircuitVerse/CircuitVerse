module ActivityNotification
  module Swagger::SubscriptionsParameters #:nodoc:
    module TargetParameters #:nodoc:
      def self.extended(base)
        base.parameter do
          key :name, :target_type
          key :in, :path
          key :description, "Target type of subscriptions: e.g. 'users'"
          key :required, true
          key :type, :string
          key :example, "users"
        end
        base.parameter do
          key :name, :target_id
          key :in, :path
          key :description, "Target ID of subscriptions. This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs."
          key :required, true
          key :type, :string
          key :example, 1
        end
      end
    end

    module IdParameter #:nodoc:
      def self.extended(base)
        base.parameter do
          key :name, :id
          key :in, :path
          key :description, 'ID of subscription record. This parameter type is integer with ActiveRecord, but will be string with Mongoid or Dynamoid ORMs.'
          key :required, true
          key :type, :string
          key :example, 123
        end
      end
    end

    module FilterByParameters #:nodoc:
      def self.extended(base)
        base.parameter do
          key :name, :filtered_by_key
          key :in, :query
          key :description, "Key of subscriptions to filter subscription index: e.g. 'comment.default'"
          key :required, false
          key :type, :string
          key :example, "comment.default"
        end
      end
    end
  end
end