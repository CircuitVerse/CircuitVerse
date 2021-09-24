# Rails 3.x hooks

require "json"
require "rails"
require "bugsnag"
require "bugsnag/middleware/rails3_request"
require "bugsnag/middleware/rack_request"
require "bugsnag/integrations/rails/rails_breadcrumbs"

module Bugsnag
  class Railtie < ::Rails::Railtie
    FRAMEWORK_ATTRIBUTES = {
      :framework => "Rails"
    }

    ##
    # Subscribes to an ActiveSupport event, leaving a breadcrumb when it triggers
    #
    # @api private
    # @param event [Hash] details of the event to subscribe to
    def event_subscription(event)
      ActiveSupport::Notifications.subscribe(event[:id]) do |*, event_id, data|
        filtered_data = data.slice(*event[:allowed_data])
        filtered_data[:event_name] = event[:id]
        filtered_data[:event_id] = event_id

        if event[:id] == "sql.active_record"
          if data.key?(:binds)
            binds = data[:binds].each_with_object({}) { |bind, output| output[bind.name] = '?' if defined?(bind.name) }
            filtered_data[:binds] = JSON.dump(binds) unless binds.empty?
          end

          # Rails < 6.1 included connection_id in the event data, but now
          # includes the connection object instead
          if data.key?(:connection) && !data.key?(:connection_id)
            # the connection ID is the object_id of the connection object
            filtered_data[:connection_id] = data[:connection].object_id
          end
        end

        Bugsnag.leave_breadcrumb(
          event[:message],
          filtered_data,
          event[:type],
          :auto
        )
      end
    end

    rake_tasks do
      require "bugsnag/integrations/rake"
      load "bugsnag/tasks/bugsnag.rake"
    end

    config.before_initialize do
      # Configure bugsnag rails defaults
      # Skipping API key validation as the key may be set later in an
      # initializer. If not, the key will be validated in after_initialize.
      Bugsnag.configure(false) do |config|
        config.logger = ::Rails.logger
        config.release_stage ||= ::Rails.env.to_s
        config.project_root = ::Rails.root.to_s
        config.internal_middleware.use(Bugsnag::Middleware::Rails3Request)
        config.runtime_versions["rails"] = ::Rails::VERSION::STRING
      end

      ActiveSupport.on_load(:action_controller) do
        require "bugsnag/integrations/rails/controller_methods"
        include Bugsnag::Rails::ControllerMethods
      end

      ActiveSupport.on_load(:active_record) do
        require "bugsnag/integrations/rails/active_record_rescue"
        include Bugsnag::Rails::ActiveRecordRescue
      end

      ActiveSupport.on_load(:active_job) do
        require "bugsnag/middleware/active_job"
        Bugsnag.configuration.internal_middleware.use(Bugsnag::Middleware::ActiveJob)

        require "bugsnag/integrations/rails/active_job"
        include Bugsnag::Rails::ActiveJob
      end

      Bugsnag::Rails::DEFAULT_RAILS_BREADCRUMBS.each { |event| event_subscription(event) }

      # Make sure we don't overwrite the value set by another integration because
      # Rails is a less specific app_type (e.g. Que sets this earlier than us)
      Bugsnag.configuration.detected_app_type ||= "rails"
    end

    # Configure meta_data_filters after initialization, so that rails initializers
    # may set filter_parameters which will be picked up by Bugsnag.
    config.after_initialize do
      Bugsnag.configure do |config|
        config.meta_data_filters += ::Rails.configuration.filter_parameters.map do |filter|
          case filter
          when String, Symbol
            /\A#{filter}\z/
          else
            filter
          end
        end
      end
    end

    initializer "bugsnag.use_rack_middleware" do |app|
      begin
        begin
          app.config.middleware.insert_after ActionDispatch::DebugExceptions, Bugsnag::Rack
        rescue
          app.config.middleware.use Bugsnag::Rack
        end
      rescue FrozenError
        # This can happen when running RSpec if there is a crash after Rails has
        # started booting but before we've added our middleware. If we don't ignore
        # this error then the stacktrace blames Bugsnag, which isn't accurate as
        # the middleware will only be frozen if an earlier error occurs
        # See this comment for more info:
        # https://github.com/thoughtbot/factory_bot_rails/issues/303#issuecomment-434560625
        Bugsnag.configuration.warn("Unable to add Bugsnag::Rack middleware as the middleware stack is frozen")
      end
    end
  end
end
