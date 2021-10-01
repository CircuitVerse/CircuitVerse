module Bugsnag::Middleware
  ##
  # Extracts data from the exception.
  class ExceptionMetaData
    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      # Apply the user's information attached to the exceptions
      report.raw_exceptions.each do |exception|
        if exception.respond_to?(:bugsnag_user_id)
          user_id = exception.bugsnag_user_id
          report.user = {id: user_id} if user_id.is_a?(String)
        end

        if exception.respond_to?(:bugsnag_context)
          context = exception.bugsnag_context
          report.context = context if context.is_a?(String)
        end

        if exception.respond_to?(:bugsnag_grouping_hash)
          group_hash = exception.bugsnag_grouping_hash
          report.grouping_hash = group_hash if group_hash.is_a?(String)
        end

        if exception.respond_to?(:bugsnag_meta_data)
          meta_data = exception.bugsnag_meta_data
          if meta_data.is_a?(Hash)
            meta_data.each do |key, value|
              report.add_tab key, value
            end
          end
        end
      end

      @bugsnag.call(report)
    end
  end
end
