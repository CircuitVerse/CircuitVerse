module Bugsnag::Middleware
  class ActiveJob
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      data = report.request_data[:active_job]

      if data
        report.add_tab(:active_job, data)
        report.automatic_context = "#{data[:job_name]}@#{data[:queue]}"
      end

      @bugsnag.call(report)
    end
  end
end
