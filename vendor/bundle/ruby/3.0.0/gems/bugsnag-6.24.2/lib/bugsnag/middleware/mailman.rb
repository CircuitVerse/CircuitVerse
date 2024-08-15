module Bugsnag::Middleware
  ##
  # Extracts and attaches mailman data to an error report
  class Mailman
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      mailman_msg = report.request_data[:mailman_msg]
      report.add_tab(:mailman, {"message" => mailman_msg}) if mailman_msg
      @bugsnag.call(report)
    end
  end
end
