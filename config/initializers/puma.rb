# frozen_string_literal: true
# Treat socket errors in these methods as normal disconnects so Puma can
# clean up the connection without reporting an internal server error.

if defined?(Puma)
  require "puma"
  require "puma/server"

  module PumaClientDisconnectPatch
    def eagerly_finish
      super
    rescue SystemCallError, IOError
      raise Puma::ConnectionError, "Connection error detected during eagerly_finish"
    end

    def finish(timeout)
      super
    rescue SystemCallError, IOError
      raise Puma::ConnectionError, "Connection error detected during finish"
    end
  end

  Puma::Client.prepend(PumaClientDisconnectPatch) unless Puma::Client <= PumaClientDisconnectPatch
end
