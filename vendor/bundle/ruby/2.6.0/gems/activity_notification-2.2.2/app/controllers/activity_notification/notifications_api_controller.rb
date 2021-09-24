module ActivityNotification
  # Controller to manage notifications API.
  class NotificationsApiController < NotificationsController
    # Include Swagger API reference
    include Swagger::NotificationsApi
    # Include CommonApiController to select target and define common methods
    include CommonApiController
    protect_from_forgery except: [:open_all]
    rescue_from ActivityNotification::NotifiableNotFoundError, with: :render_notifiable_not_found

    # Returns notification index of the target.
    #
    # GET /:target_type/:target_id/notifications
    # @overload index(params)
    #   @param [Hash] params Request parameter options for notification index
    #   @option params [String] :filter                 (nil)     Filter option to load notification index by their status (Nothing as auto, 'opened' or 'unopened')
    #   @option params [String] :limit                  (nil)     Maximum number of notifications to return
    #   @option params [String] :reverse                ('false') Whether notification index will be ordered as earliest first
    #   @option params [String] :without_grouping       ('false') Whether notification index will include group members
    #   @option params [String] :with_group_members     ('false') Whether notification index will include group members
    #   @option params [String] :filtered_by_type       (nil)     Notifiable type to filter notification index
    #   @option params [String] :filtered_by_group_type (nil)     Group type to filter notification index, valid with :filtered_by_group_id
    #   @option params [String] :filtered_by_group_id   (nil)     Group instance ID to filter notification index, valid with :filtered_by_group_type
    #   @option params [String] :filtered_by_key        (nil)     Key of notifications to filter notification index
    #   @option params [String] :later_than             (nil)     ISO 8601 format time to filter notification index later than specified time
    #   @option params [String] :earlier_than           (nil)     ISO 8601 format time to filter notification index earlier than specified time
    #   @return [JSON] count: number of notification index records, notifications: notification index
    def index
      super
      render json: {
        count: @notifications.size, 
        notifications: @notifications.as_json(notification_json_options)
      }
    end

    # Opens all notifications of the target.
    #
    # POST /:target_type/:target_id/notifications/open_all
    # @overload open_all(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filtered_by_type       (nil)     Notifiable type to filter notification index
    #   @option params [String] :filtered_by_group_type (nil)     Group type to filter notification index, valid with :filtered_by_group_id
    #   @option params [String] :filtered_by_group_id   (nil)     Group instance ID to filter notification index, valid with :filtered_by_group_type
    #   @option params [String] :filtered_by_key        (nil)     Key of notifications to filter notification index
    #   @option params [String] :later_than             (nil)     ISO 8601 format time to filter notification index later than specified time
    #   @option params [String] :earlier_than           (nil)     ISO 8601 format time to filter notification index earlier than specified time
    #   @return [JSON] count: number of opened notification records, notifications: opened notifications
    def open_all
      super
      render json: {
        count: @opened_notifications.size,
        notifications: @opened_notifications.as_json(notification_json_options)
      }
    end
  
    # Returns a single notification.
    #
    # GET /:target_type/:target_id/notifications/:id
    # @overload show(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] Found single notification
    def show
      super
      render json: notification_json
    end
  
    # Deletes a notification.
    #
    # DELETE /:target_type/:target_id/notifications/:id
    # @overload destroy(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] 204 No Content
    def destroy
      super
      head 204
    end
  
    # Opens a notification.
    #
    # PUT /:target_type/:target_id/notifications/:id/open
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :move ('false') Whether it redirects to notifiable_path after the notification is opened
    #   @return [JSON] count: number of opened notification records, notification: opened notification
    def open
      super
      unless params[:move].to_s.to_boolean(false)
        render json: {
          count: @opened_notifications_count,
          notification: notification_json
        }
      end
    end

    # Moves to notifiable_path of the notification.
    #
    # GET /:target_type/:target_id/notifications/:id/move
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :open ('false') Whether the notification will be opened
    #   @return [JSON] location: notifiable path, count: number of opened notification records, notification: specified notification
    def move
      super
      render status: 302, location: @notification.notifiable_path, json: {
        location: @notification.notifiable_path,
        count: (@opened_notifications_count || 0),
        notification: notification_json
      }
    end

    protected

      # Returns options for notification JSON
      # @api protected
      def notification_json_options
        {
          include: {
            target: { methods: [:printable_type, :printable_target_name] },
            notifiable: { methods: [:printable_type] },
            group: { methods: [:printable_type, :printable_group_name] },
            notifier: { methods: [:printable_type, :printable_notifier_name] },
            group_members: {}
          },
          methods: [:notifiable_path, :printable_notifiable_name, :group_member_notifier_count, :group_notification_count]
        }
      end

      # Returns JSON of @notification
      # @api protected
      def notification_json
        @notification.as_json(notification_json_options)
      end

      # Render associated notifiable record not found error with 500 status
      # @api protected
      # @param [Error] error Error object
      # @return [void]
      def render_notifiable_not_found(error)
        render status: 500, json: error_response(code: 500, message: "Associated record not found", type: error.message)
      end

  end
end