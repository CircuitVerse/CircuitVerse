require "net/https"
require "uri"

module Bugsnag
  module Delivery
    class Synchronous
      class << self
        ##
        # Attempts to deliver a payload to the given endpoint synchronously.
        def deliver(url, body, configuration, options={})
          begin
            response = request(url, body, configuration, options)
            configuration.debug("Request to #{url} completed, status: #{response.code}")
            if response.code[0] != "2"
              configuration.warn("Notifications to #{url} was reported unsuccessful with code #{response.code}")
            end
          rescue StandardError => e
            # KLUDGE: Since we don't re-raise http exceptions, this breaks rspec
            raise if e.class.to_s == "RSpec::Expectations::ExpectationNotMetError"

            configuration.warn("Notification to #{url} failed, #{e.inspect}")
            configuration.warn(e.backtrace)
          end
        end

        private

        def request(url, body, configuration, options)
          uri = URI.parse(url)

          if configuration.proxy_host
            http = Net::HTTP.new(uri.host, uri.port, configuration.proxy_host, configuration.proxy_port, configuration.proxy_user, configuration.proxy_password)
          else
            http = Net::HTTP.new(uri.host, uri.port)
          end

          http.read_timeout = configuration.timeout
          http.open_timeout = configuration.timeout

          if uri.scheme == "https"
            http.use_ssl = true
            http.ca_file = configuration.ca_file if configuration.ca_file
          end

          headers = options.key?(:headers) ? options[:headers] : {}
          headers.merge!(default_headers)

          request = Net::HTTP::Post.new(path(uri), headers)
          request.body = body

          http.request(request)
        end

        def path(uri)
          uri.path == "" ? "/" : uri.path
        end

        def default_headers
          {
            "Content-Type" => "application/json",
            "Bugsnag-Sent-At" => Time.now.utc.iso8601(3)
          }
        end
      end
    end
  end
end

Bugsnag::Delivery.register(:synchronous, Bugsnag::Delivery::Synchronous)
