module Bugsnag::Middleware
  ##
  # Extracts and attaches rack data to an error report
  class RackRequest
    SPOOF = "[SPOOF]".freeze

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      if report.request_data[:rack_env]
        env = report.request_data[:rack_env]

        request = ::Rack::Request.new(env)

        params = request.params rescue {}
        client_ip = request.ip.to_s rescue SPOOF
        session = env["rack.session"]

        # Set the context
        report.context = "#{request.request_method} #{request.path}"

        # Set a sensible default for user_id
        report.user["id"] = request.ip

        # Build the clean url (hide the port if it is obvious)
        url = "#{request.scheme}://#{request.host}"
        url << ":#{request.port}" unless [80, 443].include?(request.port)

        # If app is passed a bad URL, this code will crash attempting to clean it
        begin
          url << Bugsnag.cleaner.clean_url(request.fullpath)
        rescue StandardError => stde
          Bugsnag.configuration.warn "RackRequest - Rescued error while cleaning request.fullpath: #{stde}"
        end

        referer = nil
        begin
          referer = Bugsnag.cleaner.clean_url(request.referer) if request.referer
        rescue StandardError => stde
          Bugsnag.configuration.warn "RackRequest - Rescued error while cleaning request.referer: #{stde}"
        end

        headers = {}

        env.each_pair do |key, value|
          if key.to_s.start_with?("HTTP_")
            header_key = key[5..-1]
          elsif ["CONTENT_TYPE", "CONTENT_LENGTH"].include?(key)
            header_key = key
          else
            next
          end

          headers[header_key.split("_").map {|s| s.capitalize}.join("-")] = value
        end

        headers["Referer"] = referer if headers["Referer"]

        # Add a request tab
        report.add_tab(:request, {
          :url => url,
          :httpMethod => request.request_method,
          :params => params.to_hash,
          :referer => referer,
          :clientIp => client_ip,
          :headers => headers
        })

        # Add an environment tab
        if report.configuration.send_environment
          report.add_tab(:environment, env)
        end

        # Add a session tab
        if session
          if session.is_a?(Hash)
            # Rails 3
            report.add_tab(:session, session)
          elsif session.respond_to?(:to_hash)
            # Rails 4
            report.add_tab(:session, session.to_hash)
          end
        end
      end

      @bugsnag.call(report)
    end
  end
end
