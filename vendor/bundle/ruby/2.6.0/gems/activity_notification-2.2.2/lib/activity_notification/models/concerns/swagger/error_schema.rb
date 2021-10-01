module ActivityNotification
  module Swagger::ErrorSchema #:nodoc:
    extend ActiveSupport::Concern
    include ::Swagger::Blocks

    included do
      swagger_component do
        schema :Error do
          key :required, [:gem, :error]
          property :gem do
            key :type, :string
            key :description, "Name of gem generating this error"
            key :default, "activity_notification"
            key :example, "activity_notification"
          end
          property :error do
            key :type, :object
            key :description, "Error information"
            property :code do
              key :type, :integer
              key :description, "Error code: default value is HTTP status code"
            end
            property :message do
              key :type, :string
              key :description, "Error message"
            end
            property :type do
              key :type, :string
              key :description, "Error type describing error message"
            end
          end
        end
      end
    end
  end
end