module Bugsnag::Middleware
  ##
  # Extracts and attaches rails and rack environment data to an error report
  class Rails3Request
    SPOOF = "[SPOOF]".freeze

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      if report.request_data[:rack_env]
        env = report.request_data[:rack_env]
        params = env["action_dispatch.request.parameters"]
        client_ip = env["action_dispatch.remote_ip"].to_s rescue SPOOF

        if params
          # Set the context
          report.context = "#{params[:controller]}##{params[:action]}"

          # Augment the request tab
          report.add_tab(:request, {
            :railsAction => "#{params[:controller]}##{params[:action]}",
            :params => params
          })
        end

        # Use action_dispatch.remote_ip for IP address fields and send request id
        report.add_tab(:request, {
          :clientIp => client_ip,
          :requestId => env["action_dispatch.request_id"]
        })

        report.user["id"] = client_ip
      end

      @bugsnag.call(report)
    end
  end
end
