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
    end

    DEFAULT_VIEW_DIRECTORY = "default"
  
    protected

      # Sets @target instance variable from request parameters.
      # @api protected
      # @return [Object] Target instance (Returns HTTP 400 when request parameters are not enough)
      def set_target
        if (target_type = params[:target_type]).present?
          target_class = target_type.to_model_class
          @target = params[:target_id].present? ?
            target_class.find_by!(id: params[:target_id]) :
            target_class.find_by!(id: params["#{target_type.to_resource_name}_id"])
        else
          render plain: "400 Bad Request: Missing parameter", status: 400
        end
      end

      # Validate target with belonging model (e.g. Notification and Subscription)
      # @api protected
      # @param [Object] belonging_model belonging model (e.g. Notification and Subscription)
      # @return Nil or render HTTP 403 status
      def validate_target(belonging_model)
        if @target.present? && belonging_model.target != @target
          render plain: "403 Forbidden: Wrong target", status: 403
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

      # Returns JavaScript view for ajax request or redirects to back as default.
      # @api protected
      # @return [Responce] JavaScript view for ajax request or redirects to back as default
      def return_back_or_ajax
        set_index_options
        respond_to do |format|
          if request.xhr?
            load_index if params[:reload].to_s.to_boolean(true)
            format.js
          else
            compatibly_redirect_back(@index_options) and return
          end
        end
      end

      # Redirect to back.
      # @api protected
      # @return [Boolean] True
      def compatibly_redirect_back(request_params = {})
        # :only-rails5-plus#only-rails-with-callback-issue:
        # :only-rails5-plus#only-rails-without-callback-issue:
        # :only-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        # :only-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        if Rails::VERSION::MAJOR >= 5
          redirect_back fallback_location: { action: :index }, **request_params
        # :only-rails5-plus#only-rails-with-callback-issue:
        # :only-rails5-plus#only-rails-without-callback-issue:
        # :only-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        # :only-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-with-callback-issue:
        # :except-rails5-plus#only-rails-without-callback-issue:
        # :except-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        elsif request.referer
          redirect_to :back, **request_params
        else
          redirect_to action: :index, **request_params
        end
        # :except-rails5-plus#only-rails-with-callback-issue:
        # :except-rails5-plus#only-rails-without-callback-issue:
        # :except-rails5-plus#only-rails-with-callback-issue#except-dynamoid:
        # :except-rails5-plus#only-rails-without-callback-issue#except-dynamoid:
        true
      end
  end
end
