module Bugsnag::Middleware
  ##
  # Attaches information about current session to an error report
  class SessionData
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      session = Bugsnag::SessionTracker.get_current_session
      unless session.nil?
        if report.unhandled
          session[:events][:unhandled] += 1
        else
          session[:events][:handled] += 1
        end
        report.session = session
      end

      @bugsnag.call(report)
    end
  end
end
