module ActivityNotification
  # Controller to manage subscriptions API.
  class SubscriptionsApiController < SubscriptionsController
    # Include Swagger API reference
    include Swagger::SubscriptionsApi
    # Include CommonApiController to select target and define common methods
    include CommonApiController
    protect_from_forgery except: [:create]
    before_action :set_subscription, except: [:index, :create, :find, :optional_target_names]
    before_action ->{ validate_param(:key) }, only: [:find, :optional_target_names]

    # Returns subscription index of the target.
    #
    # GET /:target_type/:target_id/subscriptions
    # @overload index(params)
    #   @param [Hash] params Request parameter options for subscription index
    #   @option params [String] :filter          (nil)     Filter option to load subscription index by their configuration status (Nothing as all, 'configured' or 'unconfigured')
    #   @option params [String] :limit           (nil)     Limit to query for subscriptions
    #   @option params [String] :reverse         ('false') Whether subscription index and unconfigured notification keys will be ordered as earliest first
    #   @option params [String] :filtered_by_key (nil)     Key of the subscription for filter
    #   @return [JSON] configured_count: count of subscription index, subscriptions: subscription index, unconfigured_count: count of unconfigured notification keys, unconfigured_notification_keys: unconfigured notification keys
    def index
      super
      json_response = { configured_count: @subscriptions.size, subscriptions: @subscriptions } if @subscriptions
      json_response = (json_response || {}).merge(unconfigured_count: @notification_keys.size, unconfigured_notification_keys: @notification_keys) if @notification_keys
      render json: json_response
    end

    # Creates new subscription.
    #
    # POST /:target_type/:target_id/subscriptions
    # @overload create(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :subscription                              Subscription parameters
    #   @option params [String] :subscription[:key]                        Key of the subscription
    #   @option params [String] :subscription[:subscribing]          (nil) Whether the target will subscribe to the notification
    #   @option params [String] :subscription[:subscribing_to_email] (nil) Whether the target will subscribe to the notification email
    #   @return [JSON] Created subscription
    def create
      render_invalid_parameter("Parameter is missing or the value is empty: subscription") and return if params[:subscription].blank?
      optional_target_names = (params[:subscription][:optional_targets] || {}).keys.select { |key| !key.to_s.start_with?("subscribing_to_") }
      optional_target_names.each do |optional_target_name|
        subscribing_param = params[:subscription][:optional_targets][optional_target_name][:subscribing]
        params[:subscription][:optional_targets]["subscribing_to_#{optional_target_name}"] = subscribing_param unless subscribing_param.nil?
      end
      super
      render status: 201, json: subscription_json if @subscription
    end

    # Finds and shows a subscription from specified key.
    #
    # GET /:target_type/:target_id/subscriptions/find
    # @overload index(params)
    #   @param [Hash] params Request parameter options for subscription index
    #   @option params [required, String] :key (nil) Key of the subscription
    #   @return [JSON] Found single subscription
    def find
      super
      render json: subscription_json if @subscription
    end

    # Finds and returns configured optional_target names from specified key.
    #
    # GET /:target_type/:target_id/subscriptions/optional_target_names
    # @overload index(params)
    #   @param [Hash] params Request parameter options for subscription index
    #   @option params [required, String] :key (nil) Key of the subscription
    #   @return [JSON] Configured optional_target names
    def optional_target_names
      latest_notification = @target.notifications.filtered_by_key(params[:key]).latest
      latest_notification ?
        render(json: { configured_count: latest_notification.optional_target_names.length, optional_target_names: latest_notification.optional_target_names }) :
        render_resource_not_found("Couldn't find notification with this target and 'key'=#{params[:key]}")
    end

    # Shows a subscription.
    #
    # GET /:target_type/:target_id/subscriptions/:id
    # @overload show(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] Found single subscription
    def show
      super
      render json: subscription_json
    end
  
    # Deletes a subscription.
    #
    # DELETE /:target_type/:target_id/subscriptions/:id
    #
    # @overload destroy(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] 204 No Content
    def destroy
      super
      head 204
    end

    # Updates a subscription to subscribe to the notifications.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/subscribe
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [String] :with_email_subscription ('true') Whether the subscriber also subscribes notification email
    #   @option params [String] :with_optional_targets   ('true') Whether the subscriber also subscribes optional targets
    #   @return [JSON] Updated subscription
    def subscribe
      super
      validate_and_render_subscription
    end

    # Updates a subscription to unsubscribe to the notifications.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] Updated subscription
    def unsubscribe
      super
      validate_and_render_subscription
    end

    # Updates a subscription to subscribe to the notification email.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/subscribe_email
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] Updated subscription
    def subscribe_to_email
      super
      validate_and_render_subscription
    end

    # Updates a subscription to unsubscribe to the notification email.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe_email
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @return [JSON] Updated subscription
    def unsubscribe_to_email
      super
      validate_and_render_subscription
    end

    # Updates a subscription to subscribe to the specified optional target.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/subscribe_to_optional_target
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [required, String] :optional_target_name (nil) Class name of the optional target implementation (e.g. 'amazon_sns', 'slack')
    #   @return [JSON] Updated subscription
    def subscribe_to_optional_target
      super
      validate_and_render_subscription
    end

    # Updates a subscription to unsubscribe to the specified optional target.
    #
    # PUT /:target_type/:target_id/subscriptions/:id/unsubscribe_to_optional_target
    # @overload open(params)
    #   @param [Hash] params Request parameters
    #   @option params [required, String] :optional_target_name (nil) Class name of the optional target implementation (e.g. 'amazon_sns', 'slack')
    #   @return [JSON] Updated subscription
    def unsubscribe_to_optional_target
      super
      validate_and_render_subscription
    end

    protected

      # Returns include option for subscription JSON
      # @api protected
      def subscription_json_include_option
        [:target].freeze
      end

      # Returns methods option for subscription JSON
      # @api protected
      def subscription_json_methods_option
        [].freeze
      end

      # Returns JSON of @subscription
      # @api protected
      def subscription_json
        @subscription.as_json(include: subscription_json_include_option, methods: subscription_json_methods_option)
      end

      # Validate @subscription and render JSON of @subscription
      # @api protected
      def validate_and_render_subscription
        raise RecordInvalidError, @subscription.errors.full_messages.first if @subscription.invalid?
        render json: subscription_json
      end

  end
end