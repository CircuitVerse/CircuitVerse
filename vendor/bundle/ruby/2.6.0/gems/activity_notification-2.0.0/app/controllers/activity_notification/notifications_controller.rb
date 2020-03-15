module ActivityNotification
  # Controller to manage notifications.
  class NotificationsController < ActivityNotification.config.parent_controller.constantize
    # Include CommonController to select target and define common methods
    include CommonController
    before_action :set_notification, except: [:index, :open_all]

    # Shows notification index of the target.
    #
    # GET /:target_type/:target_id/notifications
    # @overload index(params)
    #   @param [Hash] params Request parameter options for notification index
    #   @option params [String] :filter                 (nil)     Filter option to load notification index (Nothing as auto, 'opened' or 'unopened')
    #   @option params [String] :limit                  (nil)     Limit to query for notifications
    #   @option params [String] :reverse                ('false') If notification index will be ordered as earliest first
    #   @option params [String] :without_grouping       ('false') If notification index will include group members
    #   @option params [String] :with_group_members     ('false') If notification index will include group members
    #   @option params [String] :filtered_by_type       (nil)     Notifiable type for filter
    #   @option params [String] :filtered_by_group_type (nil)     Group type for filter, valid with :filtered_by_group_id
    #   @option params [String] :filtered_by_group_id   (nil)     Group instance id for filter, valid with :filtered_by_group_type
    #   @option params [String] :filtered_by_key        (nil)     Key of the notification for filter
    #   @option params [String] :reload                 ('true')  Whether notification index will be reloaded
    #   @return [Responce] HTML view as default or JSON of notification index with json format parameter
    def index
      set_index_options
      load_index if params[:reload].to_s.to_boolean(true)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @notifications.to_json(include: [:target, :notifiable, :group]) }
      end
    end

    # Opens all notifications of the target.
    #
    # POST /:target_type/:target_id/notifications/open_all
    # @overload open_all(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filter  (nil)     Filter option to load notification index (Nothing as auto, 'opened' or 'unopened')
    #   @option params [String] :limit   (nil)     Limit to query for notifications
    #   @option params [String] :reload  ('true')  Whether notification index will be reloaded
    #   @option params [String] :without_grouping       ('false') If notification index will include group members
    #   @option params [String] :with_group_members     ('false') If notification index will include group members
    #   @option params [String] :filtered_by_type       (nil) Notifiable type for filter
    #   @option params [String] :filtered_by_group_type (nil) Group type for filter, valid only :filtered_by_group_id
    #   @option params [String] :filtered_by_group_id   (nil) Group instance id for filter, valid only :filtered_by_group_type
    #   @option params [String] :filtered_by_key        (nil) Key of the notification for filter 
    #   @return [Responce] JavaScript view for ajax request or redirects to back as default
    def open_all
      @target.open_all_notifications(params)
      return_back_or_ajax
    end
  
    # Shows a notification.
    #
    # GET /:target_type/:target_id/notifications/:id
    # @overload show(params)
    #   @param [Hash] params Request parameters
    #   @return [Responce] HTML view as default
    def show
    end
  
    # Deletes a notification.
    #
    # DELETE /:target_type/:target_id/notifications/:id
    #
    # @overload destroy(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filter             (nil)     Filter option to load notification index (Nothing as auto, 'opened' or 'unopened')
    #   @option params [String] :limit              (nil)     Limit to query for notifications
    #   @option params [String] :reload             ('true')  Whether notification index will be reloaded
    #   @option params [String] :without_grouping   ('false') If notification index will include group members
    #   @option params [String] :with_group_members ('false') If notification index will include group members
    #   @return [Responce] JavaScript view for ajax request or redirects to back as default
    def destroy
      @notification.destroy
      return_back_or_ajax
    end
  
    # Opens a notification.
    #
    # POST /:target_type/:target_id/notifications/:id/open
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :move               ('false') Whether redirects to notifiable_path after the notification is opened
    #   @option params [String] :filter             (nil)     Filter option to load notification index (Nothing as auto, 'opened' or 'unopened')
    #   @option params [String] :limit              (nil)     Limit to query for notifications
    #   @option params [String] :reload             ('true')  Whether notification index will be reloaded
    #   @option params [String] :without_grouping   ('false') If notification index will include group members
    #   @option params [String] :with_group_members ('false') If notification index will include group members
    #   @return [Responce] JavaScript view for ajax request or redirects to back as default
    def open
      with_members = !(params[:with_group_members].to_s.to_boolean(false) || params[:without_grouping].to_s.to_boolean(false))
      @notification.open!(with_members: with_members)
      params[:move].to_s.to_boolean(false) ? 
        move : 
        return_back_or_ajax
    end

    # Moves to notifiable_path of the notification.
    #
    # GET /:target_type/:target_id/notifications/:id/move
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :open    ('false') Whether the notification will be opened
    #   @option params [String] :filter  (nil)     Filter option to load notification index (Nothing as auto, 'opened' or 'unopened')
    #   @option params [String] :limit   (nil)     Limit to query for notifications
    #   @option params [String] :reload  ('true')  Whether notification index will be reloaded
    #   @return [Responce] JavaScript view for ajax request or redirects to back as default
    def move
      @notification.open! if params[:open].to_s.to_boolean(false)
      redirect_to @notification.notifiable_path
    end
  
    # Returns path of the target view templates.
    # This method has no action routing and needs to be public since it is called from view helper.
    def target_view_path
      super
    end

    protected

      # Sets @notification instance variable from request parameters.
      # @api protected
      # @return [Object] Notification instance (Returns HTTP 403 when the target of notification is different from specified target by request parameter)
      def set_notification
        validate_target(@notification = Notification.with_target.find(params[:id]))
      end

      # Sets options to load notification index from request parameters.
      # @api protected
      # @return [Hash] options to load notification index
      def set_index_options
        limit              = params[:limit].to_i > 0 ? params[:limit].to_i : nil
        reverse            = params[:reverse].present? ?
                               params[:reverse].to_s.to_boolean(false) : nil
        with_group_members = params[:with_group_members].present? || params[:without_grouping].present? ?
                               params[:with_group_members].to_s.to_boolean(false) || params[:without_grouping].to_s.to_boolean(false) : nil
        @index_options     = params.permit(:filter, :filtered_by_type, :filtered_by_group_type, :filtered_by_group_id, :filtered_by_key, :routing_scope, :devise_default_routes)
                                   .to_h.symbolize_keys
                                   .merge(limit: limit, reverse: reverse, with_group_members: with_group_members)
      end

      # Loads notification index with request parameters.
      # @api protected
      # @return [Array] Array of notification index
      def load_index
        @notifications = 
          case @index_options[:filter]
          when :opened, 'opened'
            @target.opened_notification_index_with_attributes(@index_options)
          when :unopened, 'unopened'
            @target.unopened_notification_index_with_attributes(@index_options)
          else
            @target.notification_index_with_attributes(@index_options)
          end
      end

      # Returns controller path.
      # This method is called from target_view_path method and can be overridden.
      # @api protected
      # @return [String] "activity_notification/notifications" as controller path
      def controller_path
        "activity_notification/notifications"
      end

  end
end