module Bugsnag::Middleware
  ##
  # Extracts and appends clearance user information
  class ClearanceUser
    COMMON_USER_FIELDS = [:email, :name, :first_name, :last_name, :created_at, :id]

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      if report.request_data[:rack_env] &&
        report.request_data[:rack_env][:clearance] &&
        report.request_data[:rack_env][:clearance].signed_in? &&
        report.request_data[:rack_env][:clearance].current_user

        # Extract useful user information
        user = {}
        user_object = report.request_data[:rack_env][:clearance].current_user
        if user_object
          # Build the bugsnag user info from the current user record
          COMMON_USER_FIELDS.each do |field|
            user[field] = user_object.send(field) if user_object.respond_to?(field)
          end
        end

        report.user = user unless user.empty?
      end

      @bugsnag.call(report)
    end
  end
end
