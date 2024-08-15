module Bugsnag::Middleware
  ##
  # Extracts and attaches user information from Warden to an error report
  class WardenUser
    SCOPE_PATTERN = /^warden\.user\.([^.]+)\.key$/
    COMMON_USER_FIELDS = [:email, :name, :first_name, :last_name, :created_at, :id]

    def initialize(bugsnag)
      @bugsnag = bugsnag
    end

    def call(report)
      if report.request_data[:rack_env] && report.request_data[:rack_env]["warden"]
        env = report.request_data[:rack_env]
        session = env["rack.session"] || {}

        # Find all warden user scopes
        warden_scopes = session.keys.select {|k| k.match(SCOPE_PATTERN)}.map {|k| k.gsub(SCOPE_PATTERN, '\1')}
        unless warden_scopes.empty?
          # Pick the best scope for unique id (the default is "user")
          best_scope = warden_scopes.include?("user") ? "user" : warden_scopes.first

          # Extract useful user information
          user = {}
          user_object = env["warden"].user({:scope => best_scope, :run_callbacks => false}) rescue nil
          if user_object
            # Build the user info for this scope
            COMMON_USER_FIELDS.each do |field|
              user[field] = user_object.send(field) if user_object.respond_to?(field)
            end
          end

          # We merge the first warden scope down, so that it is the main "user" for the request
          report.user = user unless user.empty?
        end
      end

      @bugsnag.call(report)
    end
  end
end
