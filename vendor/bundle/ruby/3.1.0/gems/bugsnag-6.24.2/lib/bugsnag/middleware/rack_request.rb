require "json"

module Bugsnag::Middleware
  ##
  # Extracts and attaches rack data to an error report
  class RackRequest
    SPOOF = "[SPOOF]".freeze
    COOKIE_HEADER = "Cookie".freeze

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

        # Set the automatic context
        report.automatic_context = "#{request.request_method} #{request.path}"

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

        # Add a request tab
        report.add_tab(:request, {
          :url => url,
          :httpMethod => request.request_method,
          :params => params.to_hash,
          :referer => referer,
          :clientIp => client_ip,
          :headers => format_headers(env, referer)
        })

        # add the HTTP version if present
        if env["SERVER_PROTOCOL"]
          report.add_metadata(:request, :httpVersion, env["SERVER_PROTOCOL"])
        end

        add_request_body(report, request, env)
        add_cookies(report, request)

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

    private

    def format_headers(env, referer)
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

      headers
    end

    def add_request_body(report, request, env)
      body = parsed_request_body(request, env)

      # this request may not have a body
      return unless body.is_a?(Hash) && !body.empty?

      report.add_metadata(:request, :body, body)
    end

    def parsed_request_body(request, env)
      return request.POST rescue nil if request.form_data?

      content_type = env["CONTENT_TYPE"]

      return nil if content_type.nil?

      if content_type.include?('/json') || content_type.include?('+json')
        begin
          body = request.body

          return JSON.parse(body.read)
        rescue StandardError
          return nil
        ensure
          # the body must be rewound so other things can read it after we do
          body.rewind
        end
      end

      nil
    end

    def add_cookies(report, request)
      return unless record_cookies?

      cookies = request.cookies rescue nil

      return unless cookies.is_a?(Hash) && !cookies.empty?

      report.add_metadata(:request, :cookies, cookies)
    end

    def record_cookies?
      # only record cookies in the request if none of the filters match "Cookie"
      # the "Cookie" header will be filtered as normal
      !Bugsnag.cleaner.filters_match?(COOKIE_HEADER)
    end
  end
end
