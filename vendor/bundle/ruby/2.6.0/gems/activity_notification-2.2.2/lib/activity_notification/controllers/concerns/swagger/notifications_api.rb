module ActivityNotification
  module Swagger::NotificationsApi #:nodoc:
    extend ActiveSupport::Concern
    include ::Swagger::Blocks

    included do
      include Swagger::ErrorSchema

      swagger_path '/{target_type}/{target_id}/notifications' do
        operation :get do
          key :summary, 'Get notifications'
          key :description, 'Returns notification index of the target.'
          key :operationId, 'getNotifications'
          key :tags, ['notifications']

          extend Swagger::NotificationsParameters::TargetParameters
          parameter do
            key :name, :filter
            key :in, :query
            key :description, "Filter option to load notification index by their status"
            key :required, false
            key :type, :string
            key :enum, ['auto', 'opened', 'unopened']
            key :default, 'auto'
          end
          parameter do
            key :name, :limit
            key :in, :query
            key :description, "Maximum number of notifications to return"
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :reverse
            key :in, :query
            key :description, "Whether notification index will be ordered as earliest first"
            key :required, false
            key :type, :boolean
            key :default, false
          end
          parameter do
            key :name, :without_grouping
            key :in, :query
            key :description, "Whether notification index will include group members, same as 'with_group_members'"
            key :required, false
            key :type, :boolean
            key :default, false
            key :example, true
          end
          parameter do
            key :name, :with_group_members
            key :in, :query
            key :description, "Whether notification index will include group members, same as 'without_grouping'"
            key :required, false
            key :type, :boolean
            key :default, false
          end
          extend Swagger::NotificationsParameters::FilterByParameters

          response 200 do
            key :description, "Notification index of the target"
            content 'application/json' do
              schema do
                key :type, :object
                property :count do
                  key :type, :integer
                  key :description, "Number of notification index records"
                  key :example, 1
                end
                property :notifications do
                  key :type, :array
                  items do
                    key :'$ref', :Notification
                  end
                  key :description, "Notification index, which means array of notifications of the target"
                end
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/notifications/open_all' do
        operation :post do
          key :summary, 'Open all notifications'
          key :description, 'Opens all notifications of the target.'
          key :operationId, 'openAllNotifications'
          key :tags, ['notifications']

          extend Swagger::NotificationsParameters::TargetParameters
          extend Swagger::NotificationsParameters::FilterByParameters

          response 200 do
            key :description, "Opened notifications"
            content 'application/json' do
              schema do
                key :type, :object
                property :count do
                  key :type, :integer
                  key :description, "Number of opened notification records"
                  key :example, 1
                end
                property :notifications do
                  key :type, :array
                  items do
                    key :'$ref', :Notification
                  end
                  key :description, "Opened notifications"
                end
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/notifications/{id}' do
        operation :get do
          key :summary, 'Get notification'
          key :description, 'Returns a single notification.'
          key :operationId, 'getNotification'
          key :tags, ['notifications']

          extend Swagger::NotificationsParameters::TargetParameters
          extend Swagger::NotificationsParameters::IdParameter

          response 200 do
            key :description, "Found single notification"
            content 'application/json' do
              schema do
                key :'$ref', :Notification
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end

        operation :delete do
          key :summary, 'Delete notification'
          key :description, 'Deletes a notification.'
          key :operationId, 'deleteNotification'
          key :tags, ['notifications']

          extend Swagger::NotificationsParameters::TargetParameters
          extend Swagger::NotificationsParameters::IdParameter

          response 204 do
            key :description, "No content as successfully deleted"
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/notifications/{id}/open' do
        operation :put do
          key :summary, 'Open notification'
          key :description, 'Opens a notification.'
          key :operationId, 'openNotification'
          key :tags, ['notifications']

          extend Swagger::NotificationsParameters::TargetParameters
          extend Swagger::NotificationsParameters::IdParameter
          parameter do
            key :name, :move
            key :in, :query
            key :description, "Whether it redirects to notifiable_path after the notification is opened"
            key :required, false
            key :type, :boolean
            key :default, false
          end

          response 200 do
            key :description, "Opened notification"
            content 'application/json' do
              schema do
                key :type, :object
                property :count do
                  key :type, :integer
                  key :description, "Number of opened notification records"
                  key :example, 2
                end
                property :notification do
                  key :type, :object
                  key :'$ref', :Notification
                  key :description, "Opened notification"
                end
              end
            end
          end
          response 302 do
            key :description, "Opened notification and redirection to notifiable_path"
            content 'application/json' do
              schema do
                key :type, :object
                property :location do
                  key :type, :string
                  key :format, :uri
                  key :description, "notifiable_path for redirection"
                end
                property :count do
                  key :type, :integer
                  key :description, "Number of opened notification records"
                  key :example, 2
                end
                property :notification do
                  key :type, :object
                  key :'$ref', :Notification
                  key :description, "Opened notification"
                end
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/notifications/{id}/move' do
        operation :get do
          key :summary, 'Move to notifiable_path'
          key :description, 'Moves to notifiable_path of the notification.'
          key :operationId, 'moveNotification'
          key :tags, ['notifications']

          extend Swagger::NotificationsParameters::TargetParameters
          extend Swagger::NotificationsParameters::IdParameter
          parameter do
            key :name, :open
            key :in, :query
            key :description, "Whether the notification will be opened"
            key :required, false
            key :type, :boolean
            key :default, false
          end

          response 302 do
            key :description, "Redirection to notifiable path"
            content 'application/json' do
              schema do
                property :location do
                  key :type, :string
                  key :format, :uri
                  key :description, "Notifiable path for redirection"
                end
                property :count do
                  key :type, :integer
                  key :description, "Number of opened notification records"
                  key :example, 2
                end
                property :notification do
                  key :type, :object
                  key :'$ref', :Notification
                  key :description, "Found notification to move"
                end
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end
    end
  end
end