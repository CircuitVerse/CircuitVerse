module ActivityNotification
  # Module included in controllers to select target
  module CommonController
    extend ActiveSupport::Concern

    included do
      # Include StoreController to allow ActivityNotification access to controller instance
      include StoreController
      # Include PolymorphicHelpers to resolve string extentions
      include PolymorphicHelpers

      prepend_before_action :set_target
      before_action :set_view_prefixes
      rescue_from ActivityNotification::RecordInvalidError, with: ->(e){ render_unprocessable_entity(e.message) }
    end

    DEFAULT_VIEW_DIRECTORY = "default"
  
    protected

      # Sets @target instance variable from request parameters.
      # @api protected
      # @return [Object] Target instance (Returns HTTP 400 when request parameters are invalid)
      def set_target
        if (target_type = params[:target_type]).present?
          target_class = target_type.to_model_class
          @target = params[:target_id].present? ?
            target_class.find_by!(id: params[:target_id]) :
            target_class.find_by!(id: params["#{target_type.to_resource_name[/([^\/]+)$/]}_id"])
        else
          render status: 400, json: error_response(code: 400, message: "Invalid parameter", type: "Parameter is missing or the value is empty: target_type")
        end
      end

      # Validate target with belonging model (e.g. Notification and Subscription)
      # @api protected
      # @param [Object] belonging_model belonging model (e.g. Notification and Subscription)
      # @return Nil or render HTTP 403 status
      def validate_target(belonging_model)
        if @target.present? && belonging_model.target != @target
          render status: 403, json: error_response(code: 403, message: "Forbidden because of invalid parameter", type: "Wrong target is specified")
        end
      end

      # Sets options to load resource index from request parameters.
      # This method is to be overridden.
      # @api protected
      # @return [Hash] options to load resource index
      def set_index_options
        raise NotImplementedError, "You have to implement #{self.class}##{__method__}"
      end

      # Loads resource index with request parameters.
      # This method is to be overridden.
      # @api protected
      # @return [Array] Array of resource index
      def load_index
        raise NotImplementedError, "You have to implement #{self.class}##{__method__}"
      end

      # Returns controller path.
      # This method is called from target_view_path method and can be overridden.
      # @api protected
      # @return [String] "activity_notification" as controller path
      def controller_path
        raise NotImplementedError, "You have to implement #{self.class}##{__method__}"
      end

      # Returns path of the target view templates.
      # Do not make this method public unless Rendarable module calls controller's target_view_path method to render resources.
      # @api protected
      def target_view_path
        target_type = @target.to_resources_name
        view_path = [controller_path, target_type].join('/')
        lookup_context.exists?(action_name, view_path) ?
          view_path :
          [controller_path, DEFAULT_VIEW_DIRECTORY].join('/')
      end

      # Sets view prefixes for target view path.
      # @api protected
      def set_view_prefixes
        lookup_context.prefixes.prepend(target_view_path)
      end

      # Returns error response as Hash
      # @api protected
      # @return [Hash] Error message
      def error_response(error_info = {})
        { gem: "activity_notification", error: error_info }
      end

      # Render Resource Not Found error with 404 status
      # @api protected
      # @return [void]
      def render_resource_not_found(error = nil)
        message_type = error.respond_to?(:message) ? error.message : error
        render status: 404, json: error_response(code: 404, message: "Resource not found", type: message_type)
      end

      # Render Invalid Parameter error with 400 status
      # @api protected
      # @return [void]
      def render_invalid_parameter(message)
        render status: 400, json: error_response(code: 400, message: "Invalid parameter", type: message)
      end

      # Validate param and return HTTP 400 unless it presents.
      # @api protected
      # @param [String, Symbol] param_name Parameter name to validate
      # @return [void]
      def validate_param(param_name)
        render_invalid_parameter("Parameter is missing: #{param_name}") if params[param_name].blank?
      end

      # Render Invalid Parameter error with 400 status
      # @api protected
      # @return [void]
      def render_unprocessable_entity(message)
        render status: 422, json: error_response(code: 422, message: "Unprocessable entity", type: message)
      end

      # Returns JavaScript view for ajax request or redirects to back as default.
      # @api protected
      # @return [Response] JavaScript view for ajax request or redirects to back as default
      def return_back_or_ajax
        set_index_options
        respond_to do |format|
          if request.xhr?
            load_index if params[:reload].to_s.to_boolean(true)
            format.js
          else
            redirect_back(fallback_location: { action: :index }, **@index_options) and return
          end
        end
      end
  end
end
