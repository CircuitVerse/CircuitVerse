module Bugsnag::Middleware
  ##
  # Extracts and attaches rake task information to an error report
  class Rake
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      task = report.request_data[:bugsnag_running_task]

      if task
        report.add_tab(:rake_task, {
          :name => task.name,
          :description => task.full_comment,
          :arguments => task.arg_description
        })

        report.context ||= task.name
      end

      @bugsnag.call(report)
    end
  end
end
