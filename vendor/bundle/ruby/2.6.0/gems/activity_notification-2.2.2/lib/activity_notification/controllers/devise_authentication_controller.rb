module ActivityNotification
  # Module included in controllers to authenticate with Devise module
  module DeviseAuthenticationController
    extend ActiveSupport::Concern
    include CommonController

    included do
      prepend_before_action :authenticate_devise_resource!
      before_action :authenticate_target!
    end

    protected

      # Authenticate devise resource by Devise (e.g. calling authenticate_user! method).
      # @api protected
      # @todo Needs to call authenticate method by more secure way
      # @return [Response] Redirects for unsigned in target by Devise, returns HTTP 403 without neccesary target method or returns 400 when request parameters are not enough
      def authenticate_devise_resource!
        if params[:devise_type].present?
          authenticate_method_name = "authenticate_#{params[:devise_type].to_resource_name}!"
          if respond_to?(authenticate_method_name)
            send(authenticate_method_name)
          else
            render status: 403, json: error_response(code: 403, message: "Unauthenticated with Devise")
          end
        else
          render status: 400, json: error_response(code: 400, message: "Invalid parameter", type: "Missing devise_type")
        end
      end

      # Sets @target instance variable from request parameters.
      # This method override super (ActivityNotiication::CommonController#set_target)
      # to set devise authenticated target when the target_id params is not specified.
      # @api protected
      # @return [Object] Target instance (Returns HTTP 400 when request parameters are not enough)
      def set_target
        target_type = params[:target_type]
        if params[:target_id].blank? && params["#{target_type.to_resource_name}_id"].blank?
          target_class = target_type.to_model_class
          current_resource_method_name = "current_#{params[:devise_type].to_resource_name}"
          params[:target_id] = target_class.resolve_current_devise_target(send(current_resource_method_name))
          render status: 403, json: error_response(code: 403, message: "Unauthenticated as default target") and return if params[:target_id].blank?
        end
        super
      end

      # Authenticate the target of requested notification with authenticated devise resource.
      # @api protected
      # @todo Needs to call authenticate method by more secure way
      # @return [Response] Returns HTTP 403 for unauthorized target
      def authenticate_target!
        current_resource_method_name = "current_#{params[:devise_type].to_resource_name}"
        unless @target.authenticated_with_devise?(send(current_resource_method_name))
          render status: 403, json: error_response(code: 403, message: "Unauthorized target")
        end
      end
  end
end
