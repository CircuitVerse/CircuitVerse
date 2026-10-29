# frozen_string_literal: true

# Treat socket errors in these methods as normal disconnects so Puma can
# clean up the connection without reporting an internal server error.

if defined?(Puma)
  require "puma"
  require "puma/server"

  module PumaClientDisconnectPatch
    # Catches client disconnect socket errors and translates them into Puma::ConnectionError.
    def eagerly_finish
      super
    rescue SystemCallError, IOError
      raise Puma::ConnectionError, "Connection error detected during eagerly_finish"
    end

    # Catches client disconnect socket errors during finish and translates them into Puma::ConnectionError.
    def finish(timeout)
      super
    rescue SystemCallError, IOError
      raise Puma::ConnectionError, "Connection error detected during finish"
    end
  end

  Puma::Client.prepend(PumaClientDisconnectPatch) unless Puma::Client <= PumaClientDisconnectPatch
end
