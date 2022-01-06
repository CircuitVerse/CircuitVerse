# This initializer checks if the URL is too long to be stored in the devise session to be returned to
# If the URL is too long, devise does not store it in user_return_to

module Devise
  module Controllers
    module StoreLocation

      MAX_LOCATION_SIZE = ActionDispatch::Cookies::MAX_COOKIE_SIZE / 2

      def store_location_for(resource_or_scope, location)

          if location && location.size > MAX_LOCATION_SIZE
            return
          end

          session_key = stored_location_key_for(resource_or_scope)
      
          path = extract_path_from_location(location)
          session[session_key] = path if path
      end
    end
  end
end