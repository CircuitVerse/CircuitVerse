module Bugsnag::Middleware
  ##
  # Sets the severity to info for low-importance errors
  class ClassifyError
    INFO_CLASSES = [
        "AbstractController::ActionNotFound",
        "ActionController::InvalidAuthenticityToken",
        "ActionController::ParameterMissing",
        "ActionController::UnknownAction",
        "ActionController::UnknownFormat",
        "ActionController::UnknownHttpMethod",
        "ActionDispatch::Http::MimeNegotiation::InvalidType",
        "ActiveRecord::RecordNotFound",
        "CGI::Session::CookieStore::TamperedWithCookie",
        "Mongoid::Errors::DocumentNotFound",
        "SignalException",
        "SystemExit"
    ]

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      report.raw_exceptions.each do |ex|

        ancestor_chain = ex.class.ancestors.select {
          |ancestor| ancestor.is_a?(Class)
        }.map {
          |ancestor| ancestor.to_s
        }

        INFO_CLASSES.each do |info_class|
          if ancestor_chain.include?(info_class)
            report.severity_reason = {
              :type => Bugsnag::Report::ERROR_CLASS,
              :attributes => {
                :errorClass => info_class
              }
            }
            report.severity = 'info'
            break
          end
        end
      end

      @bugsnag.call(report)
    end
  end
end
