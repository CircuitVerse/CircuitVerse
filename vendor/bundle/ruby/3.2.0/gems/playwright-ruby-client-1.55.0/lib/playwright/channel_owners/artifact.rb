require 'stringio'

module Playwright
  define_channel_owner :Artifact do
    private def after_initialize
      @absolute_path = @initializer['absolutePath']
    end

    attr_reader :absolute_path

    def path_after_finished
      if @connection.remote?
        raise "Path is not available when using browser_type.connect(). Use save_as() to save a local copy."
      end
      @channel.send_message_to_server('pathAfterFinished')
    end

    def save_as(path)
      stream = ChannelOwners::Stream.from(@channel.send_message_to_server('saveAsStream'))
      stream.save_as(path)
    end

    def read_into_buffer
      stream = ChannelOwners::Stream.from(@channel.send_message_to_server('stream'))
      stream.read_all
    end

    def failure
      @channel.send_message_to_server('failure')
    end

    def delete
      @channel.send_message_to_server('delete')
    end

    def cancel
      @channel.send_message_to_server('cancel')
    end
  end
end
