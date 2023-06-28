module IMS::LTI

  # Class for implementing an LTI Tool Provider
  #
  #     # Initialize TP object with OAuth creds and post parameters
  #     provider = IMS::LTI::ToolProvider.new(consumer_key, consumer_secret, params)
  #
  #     # Verify OAuth signature by passing the request object
  #     if provider.valid_request?(request)
  #       # success
  #     else
  #       # handle invalid OAuth
  #     end
  #
  #     if provider.outcome_service?
  #       # ready for grade write-back
  #     else
  #       # normal tool launch without grade write-back
  #     end
  #
  # If the tool was launch as an outcome service you can POST a score to the TC.
  # The POST calls all return an OutcomeResponse object which can be used to
  # handle the response appropriately.
  #
  #     # post the score to the TC, score should be a float >= 0.0 and <= 1.0
  #     # this returns an OutcomeResponse object
  #     response = provider.post_replace_result!(score)
  #     if response.success?
  #       # grade write worked
  #     elsif response.processing?
  #     elsif response.unsupported?
  #     else
  #       # failed
  #     end

  class ToolProvider < ToolBase
    # List of outcome requests made through this instance

    include DeprecatedRoleChecks
    include RoleChecks
    attr_accessor :outcome_requests
    # Message to be sent back to the ToolConsumer when the user returns
    attr_accessor :lti_errormsg, :lti_errorlog, :lti_msg, :lti_log

    # Create a new ToolProvider
    #
    # @param consumer_key [String] The OAuth consumer key
    # @param consumer_secret [String] The OAuth consumer secret
    # @param params [Hash] Set the launch parameters as described in LaunchParams
    def initialize(consumer_key, consumer_secret, params={})
      super(consumer_key, consumer_secret, params)
      @outcome_requests = []
    end

    # Check if the request was an LTI Launch Request
    def launch_request?
      lti_message_type == 'basic-lti-launch-request'
    end

    # Check if the Tool Launch expects an Outcome Result
    def outcome_service?
      !!(lis_outcome_service_url && lis_result_sourcedid)
    end

    # Return the full, given, or family name if set
    def username(default=nil)
      lis_person_name_given || lis_person_name_family || lis_person_name_full || default
    end

    # POSTs the given score to the Tool Consumer with a replaceResult
    #
    # Creates a new OutcomeRequest object and stores it in @outcome_requests
    #
    # @return [OutcomeResponse] the response from the Tool Consumer
    def post_replace_result!(score)
      new_request.post_replace_result!(score)
    end

    # POSTs a delete request to the Tool Consumer
    #
    # Creates a new OutcomeRequest object and stores it in @outcome_requests
    #
    # @return [OutcomeResponse] the response from the Tool Consumer
    def post_delete_result!
      new_request.post_delete_result!
    end

    # POSTs the given score to the Tool Consumer with a replaceResult, the
    # returned OutcomeResponse will have the score
    #
    # Creates a new OutcomeRequest object and stores it in @outcome_requests
    #
    # @return [OutcomeResponse] the response from the Tool Consumer
    def post_read_result!
      new_request.post_read_result!
    end

    # Returns the most recent OutcomeRequest
    def last_outcome_request
      @outcome_requests.last
    end

    # Convenience method for whether the last OutcomeRequest was successful
    def last_outcome_success?
      last_outcome_request && last_outcome_request.outcome_post_successful?
    end

    # If the Tool Consumer sent a URL for the user to return to this will add
    # any set messages to the URL.
    #
    # Example:
    #
    #    tc = IMS::LTI::tc.new
    #    tc.launch_presentation_return_url = "http://example.com/return"
    #    tc.lti_msg = "hi there"
    #    tc.lti_errorlog = "error happens"
    #
    #    tc.build_return_url # => "http://example.com/return?lti_msg=hi%20there&lti_errorlog=error%20happens"
    def build_return_url
      return nil unless launch_presentation_return_url
      messages = []
      %w{lti_errormsg lti_errorlog lti_msg lti_log}.each do |m|
        if message = self.send(m)
          messages << "#{m}=#{URI.escape(message)}"
        end
      end
      q_string = messages.any? ? ("?" + messages.join("&")) : ''
      launch_presentation_return_url + q_string
    end

    private

    def new_request
      @outcome_requests << OutcomeRequest.new(:consumer_key => @consumer_key,
                         :consumer_secret => @consumer_secret,
                         :lis_outcome_service_url => lis_outcome_service_url,
                         :lis_result_sourcedid =>lis_result_sourcedid)

      extend_outcome_request(@outcome_requests.last)
    end

  end
end
