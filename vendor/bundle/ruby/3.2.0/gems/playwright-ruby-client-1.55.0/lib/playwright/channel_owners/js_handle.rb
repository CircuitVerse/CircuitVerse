module Playwright
  define_channel_owner :JSHandle do
    include Utils::Errors::TargetClosedErrorMethods

    private def after_initialize
      @preview = @initializer['preview']
      @channel.on('previewUpdated', method(:on_preview_updated))
    end

    def to_s
      @preview
    end

    private def on_preview_updated(params)
      @preview = params['preview']
    end

    def evaluate(pageFunction, arg: nil)
      JavaScript::Expression.new(pageFunction, arg).evaluate(@channel)
    end

    def evaluate_handle(pageFunction, arg: nil)
      JavaScript::Expression.new(pageFunction, arg).evaluate_handle(@channel)
    end

    def get_properties
      resp = @channel.send_message_to_server('getPropertyList')
      resp.map { |prop| [prop['name'], ChannelOwner.from(prop['value'])] }.to_h
    end

    def get_property(name)
      resp = @channel.send_message_to_server('getProperty', name: name)
      ChannelOwner.from(resp)
    end

    def as_element
      nil
    end

    def dispose
      @channel.send_message_to_server('dispose')
    rescue => err
      raise if !target_closed_error?(err)
    end

    def json_value
      value = @channel.send_message_to_server('jsonValue')
      JavaScript::ValueParser.new(value).parse
    end
  end
end
