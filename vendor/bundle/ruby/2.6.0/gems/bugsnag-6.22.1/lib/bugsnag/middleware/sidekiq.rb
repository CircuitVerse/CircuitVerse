module Bugsnag::Middleware
  ##
  # Attaches Sidekiq job information to an error report
  class Sidekiq
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      sidekiq = report.request_data[:sidekiq]
      if sidekiq
        report.add_tab(:sidekiq, sidekiq)
        report.context ||= "#{sidekiq[:msg]['wrapped'] || sidekiq[:msg]['class']}@#{sidekiq[:msg]['queue']}"
      end
      @bugsnag.call(report)
    end
  end
end
