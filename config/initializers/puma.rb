# frozen_string_literal: true

# Puma Client Disconnect / Invalid Socket Race Condition Fix (Issue #7943)
#
# In Puma (including version 8.0.2), Puma::Client#eagerly_finish and Puma::Client#finish
# invoke @to_io.wait_readable to check for readable data without rescuing SystemCallError
# or IOError.
#
# When a client prematurely disconnects, aborts, or the socket file descriptor is closed
# or invalidated before/during the read wait, @to_io.wait_readable raises Errno::EBADF
# (or IOError).
#
# Everywhere else in Puma (e.g., Client#try_to_finish, Client#read_body,
# Client#read_chunked_body, and Response#fast_write_str), SystemCallError and IOError
# during socket read/write operations are caught and converted to Puma::ConnectionError.
# Puma::Server#client_error explicitly swallows Puma::ConnectionError and EOFError as
# normal client disconnection events without logging or reporting them as 500 errors.
#
# Without this patch, unhandled Errno::EBADF escapes eagerly_finish to
# Puma::Server#process_client, which treats it as an internal server error (500) and
# reports it to Sentry via lowlevel_error.
#
# This patch prepends Puma::Client to ensure SystemCallError and IOError during
# eagerly_finish and finish are properly converted to Puma::ConnectionError, matching
# Puma's internal connection error handling architecture.

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
