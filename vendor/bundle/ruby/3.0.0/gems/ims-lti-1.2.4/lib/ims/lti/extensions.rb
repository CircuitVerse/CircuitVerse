
module IMS::LTI
  module Extensions
    
    # Base functionality for creating LTI extension modules
    # See the test for this class for a simple example of how to create an extension module
    module Base
      def outcome_request_extensions
        []
      end
      
      def outcome_response_extensions
        []
      end
      
      def extend_outcome_request(request)
        outcome_request_extensions.each do |ext|
          request.extend(ext)
        end
        request
      end
      
      def extend_outcome_response(response)
        outcome_response_extensions.each do |ext|
          response.extend(ext)
        end
        response
      end
    end

    module ExtensionBase
      def outcome_request_extensions
        super
      end

      def outcome_response_extensions
        super
      end
    end
  end
end

require 'ims/lti/extensions/outcome_data'
require 'ims/lti/extensions/content'
require 'ims/lti/extensions/canvas'
