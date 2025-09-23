module Playwright
  class ChannelOwner
    include Playwright::EventEmitter

    def self.from(channel)
      channel.object
    end

    def self.from_nullable(channel)
      channel&.object
    end

    # hidden field for caching API instance.
    attr_accessor :_api

    # @param parent [Playwright::ChannelOwner|Playwright::Connection]
    # @param type [String]
    # @param guid [String]
    # @param initializer [Hash]
    def initialize(parent, type, guid, initializer)
      @objects = {}

      if parent.is_a?(ChannelOwner)
        @connection = parent.instance_variable_get(:@connection)
        @connection.send(:update_object_from_channel_owner, guid, self)
        @parent = parent
        @parent.send(:update_object_from_child, guid, self)
      elsif parent.is_a?(Connection)
        @connection = parent
        @connection.send(:update_object_from_channel_owner, guid, self)
      else
        raise ArgumentError.new('parent must be an instance of Playwright::ChannelOwner or Playwright::Connection')
      end

      @channel = Channel.new(@connection, guid, object: self)
      @type = type
      @guid = guid
      @initializer = initializer
      @event_to_subscription_mapping = {}

      after_initialize
    end

    attr_reader :channel

    private def adopt!(child)
      unless child.is_a?(ChannelOwner)
        raise ArgumentError.new("child must be a ChannelOwner: #{child.inspect}")
      end
      child.send(:update_parent, self)
    end

    def was_collected?
      @was_collected
    end

    # used only from Connection. Not intended for public use. So keep private.
    private def dispose!(reason: nil)
      # Clean up from parent and connection.
      @connection.send(:delete_object_from_channel_owner, @guid)
      @was_collected = reason == 'gc'

      # Dispose all children.
      @objects.each_value { |object| object.send(:dispose!, reason: reason) }
      @objects.clear
    end

    private def set_event_to_subscription_mapping(event_to_subscription_mapping)
      @event_to_subscription_mapping = event_to_subscription_mapping
    end

    private def update_subscription(event, enabled)
      protocol_event = @event_to_subscription_mapping[event]
      if protocol_event
        payload = {
          event: protocol_event,
          enabled: enabled,
        }
        @channel.async_send_message_to_server('updateSubscription', payload)
      end
    end

    # @override
    def on(event, callback)
      if listener_count(event) == 0
        update_subscription(event, true)
      end
      super
    end

    # @override
    def once(event, callback)
      if listener_count(event) == 0
        update_subscription(event, true)
      end
      super
    end

    # @override
    def off(event, callback)
      super
      if listener_count(event) == 0
        update_subscription(event, false)
      end
    end


    # Suppress long long inspect log and avoid RSpec from hanging up...
    def inspect
      to_s
    end

    def to_s
      "#<#{@guid}>"
    end

    private def after_initialize
    end

    private def update_parent(new_parent)
      @parent.send(:delete_object_from_child, @guid)
      new_parent.send(:update_object_from_child, @guid, self)
      @parent = new_parent
    end

    private def update_object_from_child(guid, child)
      @objects[guid] = child
    end

    private def delete_object_from_child(guid)
      @objects.delete(guid)
    end

    private def same_connection?(other)
      @connection == other.instance_variable_get(:@connection)
    end
  end

  class RootChannelOwner < ChannelOwner
    # @param connection [Playwright::Connection]
    def initialize(connection)
      super(connection, '', '', {})
    end
  end

  # namespace declaration
  module ChannelOwners ; end

  def self.define_channel_owner(class_name, &block)
    klass = Class.new(ChannelOwner)
    klass.class_eval(&block) if block
    ChannelOwners.const_set(class_name, klass)
  end
end

# load subclasses
Dir[File.join(__dir__, 'channel_owners', '*.rb')].each { |f| require f }
