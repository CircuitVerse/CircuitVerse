module ActivityNotification
  # Controller to manage Swagger API references.
  # @See https://github.com/fotinakis/swagger-blocks/blob/master/spec/lib/swagger_v3_blocks_spec.rb
  class ApidocsController < ActivityNotification.config.parent_controller.constantize
    include ::Swagger::Blocks

    swagger_root do
      key :openapi, '3.0.0'
      info version: ActivityNotification::VERSION do
        key :description, 'A default REST API created by activity_notification which provides integrated user activity notifications for Ruby on Rails'
        key :title, 'ActivityNotification'
        key :termsOfService, 'https://github.com/simukappu/activity_notification'
        contact do
          key :name, 'activity_notification community'
          key :url,  'https://github.com/simukappu/activity_notification#help'
        end
        license do
          key :name, 'MIT'
          key :url,  'https://github.com/simukappu/activity_notification/blob/master/MIT-LICENSE'
        end
      end

      server do
        key :url, 'https://activity-notification-example.herokuapp.com/api/{version}'
        key :description, 'ActivityNotification online demo including REST API'
  
        variable :version do
          key :enum, ['v2']
          key :default, :"v#{ActivityNotification::GEM_VERSION::MAJOR}"
        end
      end
      server do
        key :url, 'http://localhost:3000/api/{version}'
        key :description, 'Example Rails application at localhost including REST API'
  
        variable :version do
          key :enum, ['v2']
          key :default, :"v#{ActivityNotification::GEM_VERSION::MAJOR}"
        end
      end

      tag do
        key :name, 'notifications'
        key :description, 'Operations about user activity notifications'
        externalDocs do
          key :description, 'Find out more'
          key :url, 'https://github.com/simukappu/activity_notification#creating-notifications'
        end
      end

      tag do
        key :name, 'subscriptions'
        key :description, 'Operations about subscription management'
        externalDocs do
          key :description, 'Find out more'
          key :url, 'https://github.com/simukappu/activity_notification#subscription-management'
        end
      end
    end
  
    SWAGGERED_CLASSES = [
      Notification,
      NotificationsApiController,
      Subscription,
      SubscriptionsApiController,
      self
    ].freeze
  
    # Returns root JSON of Swagger API references.
    # GET /apidocs
    def index
      render json: ::Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
    end
  end
end