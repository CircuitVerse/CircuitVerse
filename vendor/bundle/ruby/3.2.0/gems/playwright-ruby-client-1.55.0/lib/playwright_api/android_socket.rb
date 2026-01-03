module Playwright
  #
  # `AndroidSocket` is a way to communicate with a process launched on the `AndroidDevice`. Use [`method: AndroidDevice.open`] to open a socket.
  class AndroidSocket < PlaywrightApi

    #
    # Closes the socket.
    def close
      raise NotImplementedError.new('close is not implemented yet.')
    end

    #
    # Writes some `data` to the socket.
    def write(data)
      raise NotImplementedError.new('write is not implemented yet.')
    end
  end
end
