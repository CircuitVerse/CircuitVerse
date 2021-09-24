if defined?(ActionCable)
  # Action Cable API channel to subscribe broadcasted notifications with Devise authentication.
  class ActivityNotification::NotificationApiWithDeviseChannel < ActivityNotification::NotificationApiChannel
    # Include PolymorphicHelpers to resolve string extentions
    include ActivityNotification::PolymorphicHelpers

    protected

      # Find current authenticated target from auth token headers with Devise Token Auth.
      # @api protected
      # @param [String] devise_type Class name of Devise resource to authenticate
      # @return [Object] Current authenticated target from auth token headers
      def find_current_target(devise_type = nil)
        devise_type = (devise_type || @target.notification_devise_resource.class.name).to_s
        current_target = devise_type.to_model_class.find_by!(uid: params[:uid])
        return nil unless current_target.valid_token?(params[:'access-token'], params[:client])
        current_target
      end

      # Set @target instance variable from request parameters.
      # This method overrides super (ActivityNotiication::NotificationChannel#set_target)
      # to set devise authenticated target when the target_id params is not specified.
      # @api protected
      # @return [Object] Target instance (Reject subscription when request parameters are not enough)
      def set_target
        reject and return if (target_type = params[:target_type]).blank?
        if params[:target_id].blank? && params["#{target_type.to_s.to_resource_name[/([^\/]+)$/]}_id"].blank?
          reject and return if params[:devise_type].blank?
          current_target = find_current_target(params[:devise_type])
          params[:target_id] = target_type.to_model_class.resolve_current_devise_target(current_target)
          reject and return if params[:target_id].blank?
        end
        super
      end

      # Authenticate the target of requested notification with authenticated devise resource.
      # @api protected
      # @return [Response] Returns connected or rejected
      def authenticate_target!
        current_resource = find_current_target
        reject unless @target.authenticated_with_devise?(current_resource)
      rescue
        reject
      end
  end
end
