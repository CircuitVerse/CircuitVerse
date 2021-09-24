module ActivityNotification
  module Swagger::SubscriptionsApi #:nodoc:
    extend ActiveSupport::Concern
    include ::Swagger::Blocks

    included do
      include Swagger::ErrorSchema

      swagger_path '/{target_type}/{target_id}/subscriptions' do
        operation :get do
          key :summary, 'Get subscriptions'
          key :description, 'Returns subscription index of the target.'
          key :operationId, 'getSubscriptions'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          parameter do
            key :name, :filter
            key :in, :query
            key :description, "Filter option to load subscription index by their configuration status"
            key :required, false
            key :type, :string
            key :enum, ['all', 'configured', 'unconfigured']
            key :default, 'all'
          end
          parameter do
            key :name, :limit
            key :in, :query
            key :description, "Maximum number of subscriptions to return"
            key :required, false
            key :type, :integer
          end
          parameter do
            key :name, :reverse
            key :in, :query
            key :description, "Whether subscription index and unconfigured notification keys will be ordered as earliest first"
            key :required, false
            key :type, :boolean
            key :default, false
          end
          extend Swagger::SubscriptionsParameters::FilterByParameters

          response 200 do
            key :description, "Subscription index of the target"
            content 'application/json' do
              schema do
                key :type, :object
                property :configured_count do
                  key :type, :integer
                  key :description, "Number of configured subscription records"
                  key :example, 1
                end
                property :subscriptions do
                  key :type, :array
                  items do
                    key :'$ref', :Subscription
                  end
                  key :description, "Subscription index, which means array of configured subscriptions of the target"
                end
                property :unconfigured_count do
                  key :type, :integer
                  key :description, "Number of unconfigured notification keys"
                  key :example, 1
                end
                property :unconfigured_notification_keys do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, "article.default"
                  end
                  key :description, "Unconfigured notification keys, which means array of configured notification keys of the target to configure subscriptions"
                end
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
        end

        operation :post do
          key :summary, 'Create subscription'
          key :description, 'Creates new subscription.'
          key :operationId, 'createSubscription'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          parameter do
            key :name, :subscription
            key :in, :body
            key :description, 'Subscription parameters'
            key :required, true
            schema do
              key :'$ref', :SubscriptionInput
            end
          end

          response 201 do
            key :description, "Created subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/find' do
        operation :get do
          key :summary, 'Find subscription'
          key :description, 'Find and returns a single subscription.'
          key :operationId, 'findSubscription'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          parameter do
            key :name, :key
            key :in, :query
            key :description, "Key of the subscription to find"
            key :required, true
            key :type, :string
          end

          response 200 do
            key :description, "Found single subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/optional_target_names' do
        operation :get do
          key :summary, 'Find configured optional_target names'
          key :description, 'Finds and returns configured optional_target names from specified key.'
          key :operationId, 'findOptionalTargetNames'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          parameter do
            key :name, :key
            key :in, :query
            key :description, "Key of the notification and subscription to find"
            key :required, true
            key :type, :string
          end

          response 200 do
            key :description, "Found configured optional_target names"
            content 'application/json' do
              schema do
                key :type, :object
                property :configured_count do
                  key :type, :integer
                  key :description, "Number of configured optional_target names"
                  key :example, 1
                end
                property :optional_target_names do
                  key :type, :array
                  items do
                    key :type, :string
                    key :example, "action_cable_channel"
                  end
                  key :description, "Configured optional_target names"
                end
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}' do
        operation :get do
          key :summary, 'Get subscription'
          key :description, 'Returns a single subscription.'
          key :operationId, 'getSubscription'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter

          response 200 do
            key :description, "Found single subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end

        operation :delete do
          key :summary, 'Delete subscription'
          key :description, 'Deletes a subscription.'
          key :operationId, 'deleteSubscription'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter

          response 204 do
            key :description, "No content as successfully deleted"
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}/subscribe' do
        operation :put do
          key :summary, 'Subscribe to notifications'
          key :description, 'Updates a subscription to subscribe to the notifications.'
          key :operationId, 'subscribeNotifications'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter
          parameter do
            key :name, :with_email_subscription
            key :in, :query
            key :description, "Whether the subscriber (target) also subscribes notification email"
            key :required, false
            key :type, :boolean
            key :default, true
          end
          parameter do
            key :name, :with_optional_targets
            key :in, :query
            key :description, "Whether the subscriber (target) also subscribes optional targets"
            key :required, false
            key :type, :boolean
            key :default, true
          end

          response 200 do
            key :description, "Updated subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}/unsubscribe' do
        operation :put do
          key :summary, 'Unsubscribe to notifications'
          key :description, 'Updates a subscription to unsubscribe to the notifications.'
          key :operationId, 'unsubscribeNotifications'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter

          response 200 do
            key :description, "Updated subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}/subscribe_to_email' do
        operation :put do
          key :summary, 'Subscribe to notification email'
          key :description, 'Updates a subscription to subscribe to the notification email.'
          key :operationId, 'subscribeNotificationEmail'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter

          response 200 do
            key :description, "Updated subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}/unsubscribe_to_email' do
        operation :put do
          key :summary, 'Unsubscribe to notification email'
          key :description, 'Updates a subscription to unsubscribe to the notification email.'
          key :operationId, 'unsubscribeNotificationEmail'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter

          response 200 do
            key :description, "Updated subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}/subscribe_to_optional_target' do
        operation :put do
          key :summary, 'Subscribe to optional target'
          key :description, 'Updates a subscription to subscribe to the specified optional target.'
          key :operationId, 'subscribeOptionalTarget'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter
          parameter do
            key :name, :optional_target_name
            key :in, :query
            key :description, "Class name of the optional target implementation: e.g. 'amazon_sns', 'slack' and so on"
            key :required, true
            key :type, :string
            key :example, "slack"
          end

          response 200 do
            key :description, "Updated subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end

      swagger_path '/{target_type}/{target_id}/subscriptions/{id}/unsubscribe_to_optional_target' do
        operation :put do
          key :summary, 'Unsubscribe to optional target'
          key :description, 'Updates a subscription to unsubscribe to the specified optional target.'
          key :operationId, 'unsubscribeOptionalTarget'
          key :tags, ['subscriptions']

          extend Swagger::SubscriptionsParameters::TargetParameters
          extend Swagger::SubscriptionsParameters::IdParameter
          parameter do
            key :name, :optional_target_name
            key :in, :query
            key :description, "Class name of the optional target implementation: e.g. 'amazon_sns', 'slack' and so on"
            key :required, true
            key :type, :string
            key :example, "slack"
          end

          response 200 do
            key :description, "Updated subscription"
            content 'application/json' do
              schema do
                key :'$ref', :Subscription
              end
            end
          end
          extend Swagger::ErrorResponses::InvalidParameterError
          extend Swagger::ErrorResponses::ForbiddenError
          extend Swagger::ErrorResponses::ResourceNotFoundError
          extend Swagger::ErrorResponses::UnprocessableEntityError
        end
      end
    end
  end
end