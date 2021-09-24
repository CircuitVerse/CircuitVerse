module ActivityNotification
  # Controller to manage subscriptions.
  class SubscriptionsController < ActivityNotification.config.parent_controller.constantize
    # Include CommonController to select target and define common methods
    include CommonController
    before_action :set_subscription, except: [:index, :create, :find]
    before_action ->{ validate_param(:key) },                  only: [:find]
    before_action ->{ validate_param(:optional_target_name) }, only: [:subscribe_to_optional_target, :unsubscribe_to_optional_target]

    # Shows subscription index of the target.
    #
    # GET /:target_type/:target_id/subscriptions
    # @overload index(params)
    #   @param [Hash] params Request parameter options for subscription index
    #   @option params [String] :filter          (nil)     Filter option to load subscription index by their configuration status (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)     Key of the subscription for filter
    #   @return [Response] HTML view of subscription index
    def index
      set_index_options
      load_index if params[:reload].to_s.to_boolean(true)
    end

    # Creates new subscription.
    #
    # PUT /:target_type/:target_id/subscriptions
    # @overload create(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :subscription                              Subscription parameters
    #   @option params [String] :subscription[:key]                        Key of the subscription
    #   @option params [String] :subscription[:subscribing]          (nil) Whether the target will subscribe to the notification
    #   @option params [String] :subscription[:subscribing_to_email] (nil) Whether the target will subscribe to the notification email
    #   @option params [String] :filter          (nil)                     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)                     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false')                 Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)                     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def create
      @subscription = @target.create_subscription(subscription_params)
      return_back_or_ajax
    end

    # Finds and shows a subscription from specified key.
    #
    # GET /:target_type/:target_id/subscriptions/find
    # @overload index(params)
    #   @param [Hash] params Request parameter options for subscription index
    #   @option params [required, String] :key (nil) Key of the subscription
    #   @return [Response] HTML view as default or JSON of subscription index with json format parameter
    def find
      @subscription = @target.find_subscription(params[:key])
      @subscription ? redirect_to_subscription_path : render_resource_not_found("Couldn't find subscription with this target and 'key'=#{params[:key]}")
    end

    # Shows a subscription.
    #
    # GET /:target_type/:target_id/subscriptions/:id
    # @overload show(params)
    #   @param [Hash] params Request parameters
    #   @return [Response] HTML view as default
    def show
      set_index_options
    end
  
    # Deletes a subscription.
    #
    # DELETE /:target_type/:target_id/subscriptions/:id
    # @overload destroy(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filter          (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def destroy
      @subscription.destroy
      return_back_or_ajax
    end

    # Updates a subscription to subscribe to notifications.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/subscribe
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :with_email_subscription ('true')  Whether the subscriber also subscribes notification email
    #   @option params [String] :with_optional_targets   ('true')  Whether the subscriber also subscribes optional targets
    #   @option params [String] :filter                  (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit                   (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse                 ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key         (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def subscribe
      @subscription.subscribe(with_email_subscription: params[:with_email_subscription].to_s.to_boolean(ActivityNotification.config.subscribe_to_email_as_default),
                              with_optional_targets:   params[:with_optional_targets].to_s.to_boolean(ActivityNotification.config.subscribe_to_optional_targets_as_default))
      return_back_or_ajax
    end

    # Updates a subscription to unsubscribe to the notifications.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filter          (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def unsubscribe
      @subscription.unsubscribe
      return_back_or_ajax
    end

    # Updates a subscription to subscribe to the notification email.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/subscribe_email
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filter          (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def subscribe_to_email
      @subscription.subscribe_to_email
      return_back_or_ajax
    end

    # Updates a subscription to unsubscribe to the notification email.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe_email
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :filter          (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def unsubscribe_to_email
      @subscription.unsubscribe_to_email
      return_back_or_ajax
    end

    # Updates a subscription to subscribe to the specified optional target.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/subscribe_to_optional_target
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [required, String] :optional_target_name (nil)     Class name of the optional target implementation (e.g. 'amazon_sns', 'slack')
    #   @option params [String]           :filter               (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String]           :limit                (nil)     Limit to query for subscriptions
    #   @option params [String]           :reverse              ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String]           :filtered_by_key      (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def subscribe_to_optional_target
      @subscription.subscribe_to_optional_target(params[:optional_target_name])
      return_back_or_ajax
    end

    # Updates a subscription to unsubscribe to the specified optional target.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe_to_optional_target
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [required, String] :optional_target_name (nil)     Class name of the optional target implementation (e.g. 'amazon_sns', 'slack')
    #   @option params [String]           :filter               (nil)     Filter option to load subscription index (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String]           :limit                (nil)     Limit to query for subscriptions
    #   @option params [String]           :reverse              ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String]           :filtered_by_key      (nil)     Key of the subscription for filter
    #   @return [Response] JavaScript view for ajax request or redirects to back as default
    def unsubscribe_to_optional_target
      @subscription.unsubscribe_to_optional_target(params[:optional_target_name])
      return_back_or_ajax
    end

    protected

      # Sets @subscription instance variable from request parameters.
      # @api protected
      # @return [Object] Subscription instance (Returns HTTP 403 when the target of subscription is different from specified target by request parameter)
      def set_subscription
        validate_target(@subscription = Subscription.with_target.find(params[:id]))
      end

      # Only allow a trusted parameter "white list" through.
      def subscription_params
        if params[:subscription].present?
          optional_target_keys = (params[:subscription][:optional_targets] || {}).keys.select { |key| key.to_s.start_with?("subscribing_to_") }
          optional_target_keys.each do |optional_target_key|
            boolean_value = params[:subscription][:optional_targets][optional_target_key].respond_to?(:to_boolean) ? params[:subscription][:optional_targets][optional_target_key].to_boolean : !!params[:subscription][:optional_targets][optional_target_key]
            params[:subscription][:optional_targets][optional_target_key] = boolean_value
          end
        end
        params.require(:subscription).permit(:key, :subscribing, :subscribing_to_email, optional_targets: optional_target_keys)
      end

      # Sets options to load subscription index from request parameters.
      # @api protected
      # @return [Hash] options to load subscription index
      def set_index_options
        limit          = params[:limit].to_i > 0 ? params[:limit].to_i : nil
        reverse        = params[:reverse].present? ?
                           params[:reverse].to_s.to_boolean(false) : nil
        @index_options = params.permit(:filter, :filtered_by_key, :routing_scope, :devise_default_routes)
                               .to_h.symbolize_keys.merge(limit: limit, reverse: reverse)
      end

      # Loads subscription index with request parameters.
      # @api protected
      # @return [Array] Array of subscription index
      def load_index
        case @index_options[:filter]
        when :configured, 'configured'
          @subscriptions = @target.subscription_index(@index_options.merge(with_target: true))
          @notification_keys = nil
        when :unconfigured, 'unconfigured'
          @subscriptions = nil
          @notification_keys = @target.notification_keys(@index_options.merge(filter: :unconfigured))
        else
          @subscriptions = @target.subscription_index(@index_options.merge(with_target: true))
          @notification_keys = @target.notification_keys(@index_options.merge(filter: :unconfigured))
        end
      end

      # Redirect to subscription path
      # @api protected
      def redirect_to_subscription_path
        redirect_to action: :show, id: @subscription
      end

      # Returns controller path.
      # This method is called from target_view_path method and can be overridden.
      # @api protected
      # @return [String] "activity_notification/subscriptions" as controller path
      def controller_path
        "activity_notification/subscriptions"
      end

  end
end