module ActivityNotification
  # Defines API for subscription included in Subscription model.
  module SubscriptionApi
    extend ActiveSupport::Concern

    included do
      # :nocov:
      unless ActivityNotification.config.orm == :dynamoid
        # Selects filtered subscriptions by key.
        # @example Get filtered subscriptions of the @user with key 'comment.reply'
        #   @subscriptions = @user.subscriptions.filtered_by_key('comment.reply')
        # @scope class
        # @param [String] key Key of the subscription for filter
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of filtered subscriptions
        scope :filtered_by_key,     ->(key) { where(key: key) }

        # Selects filtered subscriptions by key with filter options.
        # @example Get filtered subscriptions of the @user with key 'comment.reply'
        #   @subscriptions = @user.subscriptions.filtered_by_key('comment.reply')
        # @example Get custom filtered subscriptions of the @user
        #   @subscriptions = @user.subscriptions.filtered_by_options({ custom_filter: ["created_at >= ?", time.hour.ago] })
        # @scope class
        # @param [Hash] options Options for filter
        # @option options [String]     :filtered_by_key        (nil) Key of the subscription for filter
        # @option options [Array|Hash] :custom_filter          (nil) Custom subscription filter (e.g. ["created_at >= ?", time.hour.ago] or ['created_at.gt': time.hour.ago])
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of filtered subscriptions
        scope :filtered_by_options, ->(options = {}) {
          options = ActivityNotification.cast_to_indifferent_hash(options)
          filtered_subscriptions = all
          if options.has_key?(:filtered_by_key)
            filtered_subscriptions = filtered_subscriptions.filtered_by_key(options[:filtered_by_key])
          end
          if options.has_key?(:custom_filter)
            filtered_subscriptions = filtered_subscriptions.where(options[:custom_filter])
          end
          filtered_subscriptions
        }

        # Orders by latest (newest) first as created_at: :desc.
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of subscriptions ordered by latest first
        scope :latest_order,              -> { order(created_at: :desc) }

        # Orders by earliest (older) first as created_at: :asc.
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of subscriptions ordered by earliest first
        scope :earliest_order,            -> { order(created_at: :asc) }

        # Orders by latest (newest) first as created_at: :desc.
        # This method is to be overridden in implementation for each ORM.
        # @param [Boolean] reverse If subscriptions will be ordered as earliest first
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of ordered subscriptions
        scope :latest_order!,             ->(reverse = false) { reverse ? earliest_order : latest_order }

        # Orders by earliest (older) first as created_at: :asc.
        # This method is to be overridden in implementation for each ORM.
        # @return [ActiveRecord_AssociationRelation<Notificaion>, Mongoid::Criteria<Notificaion>] Database query of subscriptions ordered by earliest first
        scope :earliest_order!,           -> { earliest_order }

        # Orders by latest (newest) first as subscribed_at: :desc.
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of subscriptions ordered by latest subscribed_at first
        scope :latest_subscribed_order,   -> { order(subscribed_at: :desc) }

        # Orders by earliest (older) first as subscribed_at: :asc.
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of subscriptions ordered by earliest subscribed_at first
        scope :earliest_subscribed_order, -> { order(subscribed_at: :asc) }

        # Orders by key name as key: :asc.
        # @return [ActiveRecord_AssociationRelation<Subscription>, Mongoid::Criteria<Notificaion>] Database query of subscriptions ordered by key name
        scope :key_order,                 -> { order(key: :asc) }

        # Convert Time value to store in database as Hash value.
        # @param [Time] time Time value to store in database as Hash value
        # @return [Time, Object] Converted Time value
        def self.convert_time_as_hash(time)
          time
        end
      end
      # :nocov:
    end

    class_methods do
      # Returns key of optional_targets hash from symbol class name of the optional target implementation.
      # @param [String, Symbol] optional_target_name Class name of the optional target implementation (e.g. :amazon_sns, :slack)
      # @return [Symbol] Key of optional_targets hash
      def to_optional_target_key(optional_target_name)
        ("subscribing_to_" + optional_target_name.to_s).to_sym
      end

      # Returns subscribed_at parameter key of optional_targets hash from symbol class name of the optional target implementation.
      # @param [String, Symbol] optional_target_name Class name of the optional target implementation (e.g. :amazon_sns, :slack)
      # @return [Symbol] Subscribed_at parameter key of optional_targets hash
      def to_optional_target_subscribed_at_key(optional_target_name)
        ("subscribed_to_" + optional_target_name.to_s + "_at").to_sym
      end

      # Returns unsubscribed_at parameter key of optional_targets hash from symbol class name of the optional target implementation.
      # @param [String, Symbol] optional_target_name Class name of the optional target implementation (e.g. :amazon_sns, :slack)
      # @return [Symbol] Unsubscribed_at parameter key of optional_targets hash
      def to_optional_target_unsubscribed_at_key(optional_target_name)
        ("unsubscribed_to_" + optional_target_name.to_s + "_at").to_sym
      end
    end

    # Override as_json method for optional_targets representation
    #
    # @param [Hash] options Options for as_json method
    # @return [Hash] Hash representing the subscription model
    def as_json(options = {})
      json = super(options).with_indifferent_access
      optional_targets_json = {}
      optional_target_names.each do |optional_target_name|
        optional_targets_json[optional_target_name] = {
          subscribing:   json[:optional_targets][Subscription.to_optional_target_key(optional_target_name)],
          subscribed_at: json[:optional_targets][Subscription.to_optional_target_subscribed_at_key(optional_target_name)],
          unsubscribed_at: json[:optional_targets][Subscription.to_optional_target_unsubscribed_at_key(optional_target_name)]
        }
      end
      json[:optional_targets] = optional_targets_json
      json
    end

    # Subscribes to the notification and notification email.
    #
    # @param [Hash] options Options for subscribing to the notification
    # @option options [DateTime] :subscribed_at           (Time.current) Time to set to subscribed_at and subscribed_to_email_at of the subscription record
    # @option options [Boolean]  :with_email_subscription (true)         If the subscriber also subscribes notification email
    # @option options [Boolean]  :with_optional_targets   (true)         If the subscriber also subscribes optional_targets
    # @return [Boolean] If successfully updated subscription instance
    def subscribe(options = {})
      subscribed_at = options[:subscribed_at] || Time.current
      with_email_subscription = options.has_key?(:with_email_subscription) ? options[:with_email_subscription] : ActivityNotification.config.subscribe_to_email_as_default
      with_optional_targets   = options.has_key?(:with_optional_targets) ? options[:with_optional_targets] : ActivityNotification.config.subscribe_to_optional_targets_as_default
      new_attributes = { subscribing: true, subscribed_at: subscribed_at, optional_targets: optional_targets }
      new_attributes = new_attributes.merge(subscribing_to_email: true, subscribed_to_email_at: subscribed_at) if with_email_subscription
      if with_optional_targets
        optional_target_names.each do |optional_target_name|
          new_attributes[:optional_targets] = new_attributes[:optional_targets].merge(
            Subscription.to_optional_target_key(optional_target_name) => true,
            Subscription.to_optional_target_subscribed_at_key(optional_target_name) => Subscription.convert_time_as_hash(subscribed_at))
        end
      end
      update(new_attributes)
    end

    # Unsubscribes to the notification and notification email.
    #
    # @param [Hash] options Options for unsubscribing to the notification
    # @option options [DateTime] :unsubscribed_at (Time.current) Time to set to unsubscribed_at and unsubscribed_to_email_at of the subscription record
    # @return [Boolean] If successfully updated subscription instance
    def unsubscribe(options = {})
      unsubscribed_at = options[:unsubscribed_at] || Time.current
      new_attributes = { subscribing:          false, unsubscribed_at:          unsubscribed_at,
                         subscribing_to_email: false, unsubscribed_to_email_at: unsubscribed_at,
                         optional_targets: optional_targets }
      optional_target_names.each do |optional_target_name|
        new_attributes[:optional_targets] = new_attributes[:optional_targets].merge(
          Subscription.to_optional_target_key(optional_target_name) => false,
          Subscription.to_optional_target_unsubscribed_at_key(optional_target_name) => Subscription.convert_time_as_hash(subscribed_at))
      end
      update(new_attributes)
    end

    # Subscribes to the notification email.
    #
    # @param [Hash] options Options for subscribing to the notification email
    # @option options [DateTime] :subscribed_to_email_at (Time.current) Time to set to subscribed_to_email_at of the subscription record
    # @return [Boolean] If successfully updated subscription instance
    def subscribe_to_email(options = {})
      subscribed_to_email_at = options[:subscribed_to_email_at] || Time.current
      update(subscribing_to_email: true, subscribed_to_email_at: subscribed_to_email_at)
    end

    # Unsubscribes to the notification email.
    #
    # @param [Hash] options Options for unsubscribing the notification email
    # @option options [DateTime] :subscribed_to_email_at (Time.current) Time to set to subscribed_to_email_at of the subscription record
    # @return [Boolean] If successfully updated subscription instance
    def unsubscribe_to_email(options = {})
      unsubscribed_to_email_at = options[:unsubscribed_to_email_at] || Time.current
      update(subscribing_to_email: false, unsubscribed_to_email_at: unsubscribed_to_email_at)
    end

    # Returns if the target subscribes to the specified optional target.
    #
    # @param [Symbol]  optional_target_name Symbol class name of the optional target implementation (e.g. :amazon_sns, :slack)
    # @param [Boolean] subscribe_as_default Default subscription value to use when the subscription record does not configured
    # @return [Boolean] If the target subscribes to the specified optional target
    def subscribing_to_optional_target?(optional_target_name, subscribe_as_default = ActivityNotification.config.subscribe_to_optional_targets_as_default)
      optional_target_key = Subscription.to_optional_target_key(optional_target_name)
      subscribe_as_default ?
        !optional_targets.has_key?(optional_target_key) || optional_targets[optional_target_key] :
         optional_targets.has_key?(optional_target_key) && optional_targets[optional_target_key]
    end

    # Subscribes to the specified optional target.
    #
    # @param [String, Symbol]  optional_target_name Symbol class name of the optional target implementation (e.g. :amazon_sns, :slack)
    # @param [Hash]            options              Options for unsubscribing to the specified optional target
    # @option options [DateTime] :subscribed_at (Time.current) Time to set to subscribed_[optional_target_name]_at in optional_targets hash of the subscription record
    # @return [Boolean] If successfully updated subscription instance
    def subscribe_to_optional_target(optional_target_name, options = {})
      subscribed_at = options[:subscribed_at] || Time.current
      update(optional_targets: optional_targets.merge(
        Subscription.to_optional_target_key(optional_target_name) => true,
        Subscription.to_optional_target_subscribed_at_key(optional_target_name) => Subscription.convert_time_as_hash(subscribed_at))
      )
    end

    # Unsubscribes to the specified optional target.
    #
    # @param [String, Symbol] optional_target_name Class name of the optional target implementation (e.g. :amazon_sns, :slack)
    # @param [Hash]           options              Options for unsubscribing to the specified optional target
    # @option options [DateTime] :unsubscribed_at (Time.current) Time to set to unsubscribed_[optional_target_name]_at in optional_targets hash of the subscription record
    # @return [Boolean] If successfully updated subscription instance
    def unsubscribe_to_optional_target(optional_target_name, options = {})
      unsubscribed_at = options[:unsubscribed_at] || Time.current
      update(optional_targets: optional_targets.merge(
        Subscription.to_optional_target_key(optional_target_name) => false,
        Subscription.to_optional_target_unsubscribed_at_key(optional_target_name) => Subscription.convert_time_as_hash(unsubscribed_at))
      )
    end

    # Returns optional_target names of the subscription from optional_targets field.
    # @return [Array<Symbol>] Array of optional target names
    def optional_target_names
      optional_targets.keys.select { |key| key.to_s.start_with?("subscribing_to_") }.map { |key| key.slice(15..-1) }
    end

    protected

      # Validates subscribing_to_email cannot be true when subscribing is false.
      def subscribing_to_email_cannot_be_true_when_subscribing_is_false
        if !subscribing && subscribing_to_email?
          errors.add(:subscribing_to_email, "cannot be true when subscribing is false")
        end
      end

      # Validates subscribing_to_optional_target cannot be true when subscribing is false.
      def subscribing_to_optional_target_cannot_be_true_when_subscribing_is_false
        optional_target_names.each do |optional_target_name|
          if !subscribing && subscribing_to_optional_target?(optional_target_name)
            errors.add(:optional_targets, "#Subscription.to_optional_target_key(optional_target_name) cannot be true when subscribing is false")
          end
        end
      end

  end
end
