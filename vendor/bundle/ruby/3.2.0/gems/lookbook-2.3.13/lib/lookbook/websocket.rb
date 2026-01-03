module Lookbook
  class Websocket
    class << self
      def new(mount_path, **kwargs)
        require_relative "cable/cable"

        Cable.new(mount_path, **kwargs)
      rescue LoadError
        NullWebsocket.new
      end
    end
  end
end
