# frozen_string_literal: true

require "action_dispatch/http/request"

module ActionDispatch
  # This middleware guards from DNS rebinding attacks by explicitly permitting
  # the hosts a request can be sent to.
  #
  # When a request comes to an unauthorized host, the +response_app+
  # application will be executed and rendered. If no +response_app+ is given, a
  # default one will run, which responds with +403 Forbidden+.
  class HostAuthorization
    class Permissions # :nodoc:
      def initialize(hosts)
        @hosts = sanitize_hosts(hosts)
      end

      def empty?
        @hosts.empty?
      end

      def allows?(host)
        @hosts.any? do |allowed|
          allowed === host
        rescue
          # IPAddr#=== raises an error if you give it a hostname instead of
          # IP. Treat similar errors as blocked access.
          false
        end
      end

      private
        def sanitize_hosts(hosts)
          Array(hosts).map do |host|
            case host
            when Regexp then sanitize_regexp(host)
            when String then sanitize_string(host)
            else host
            end
          end
        end

        def sanitize_regexp(host)
          /\A#{host}\z/
        end

        def sanitize_string(host)
          if host.start_with?(".")
            /\A(.+\.)?#{Regexp.escape(host[1..-1])}\z/i
          else
            /\A#{Regexp.escape host}\z/i
          end
        end
    end

    DEFAULT_RESPONSE_APP = -> env do
      request = Request.new(env)

      format = request.xhr? ? "text/plain" : "text/html"
      template = DebugView.new(host: request.host)
      body = template.render(template: "rescues/blocked_host", layout: "rescues/layout")

      [403, {
        "Content-Type" => "#{format}; charset=#{Response.default_charset}",
        "Content-Length" => body.bytesize.to_s,
      }, [body]]
    end

    def initialize(app, hosts, response_app = nil)
      @app = app
      @permissions = Permissions.new(hosts)
      @response_app = response_app || DEFAULT_RESPONSE_APP
    end

    def call(env)
      return @app.call(env) if @permissions.empty?

      request = Request.new(env)

      if authorized?(request)
        mark_as_authorized(request)
        @app.call(env)
      else
        @response_app.call(env)
      end
    end

    private
      def authorized?(request)
        valid_host = /
          \A
          (?<host>[a-z0-9.-]+|\[[a-f0-9]*:[a-f0-9.:]+\])
          (:\d+)?
          \z
        /x

        origin_host = valid_host.match(
          request.get_header("HTTP_HOST").to_s.downcase)
        forwarded_host = valid_host.match(
          request.x_forwarded_host.to_s.split(/,\s?/).last)

        origin_host && @permissions.allows?(origin_host[:host]) && (
          forwarded_host.nil? || @permissions.allows?(forwarded_host[:host]))
      end

      def mark_as_authorized(request)
        request.set_header("action_dispatch.authorized_host", request.host)
      end
  end
end
