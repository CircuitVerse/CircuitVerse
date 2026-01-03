module IMS::LTI
  # Class for implementing an LTI Tool Consumer
  class ToolConsumer < ToolBase
    attr_accessor :launch_url, :timestamp, :nonce

    # Create a new ToolConsumer
    #
    # @param consumer_key [String] The OAuth consumer key
    # @param consumer_secret [String] The OAuth consumer secret
    # @param params [Hash] Set the launch parameters as described in LaunchParams
    def initialize(consumer_key, consumer_secret, params={})
      super(consumer_key, consumer_secret, params)
      @launch_url = params['launch_url']
    end
    
    def process_post_request(post_request)
      request = extend_outcome_request(OutcomeRequest.new)
      request.process_post_request(post_request)
    end

    # Set launch data from a ToolConfig
    #
    # @param config [ToolConfig]
    def set_config(config)
      @launch_url ||= config.secure_launch_url
      @launch_url ||= config.launch_url
      # any parameters already set will take priority
      @custom_params = config.custom_params.merge(@custom_params)
    end

    # Check if the required parameters for a tool launch are set
    def has_required_params?
      @consumer_key && @consumer_secret && @resource_link_id && @launch_url
    end

    # Generate the launch data including the necessary OAuth information
    #
    #
    def generate_launch_data
      raise IMS::LTI::InvalidLTIConfigError, "Not all required params set for tool launch" unless has_required_params?

      params = self.to_params
      params['lti_version'] ||= 'LTI-1p0'
      params['lti_message_type'] ||= 'basic-lti-launch-request'
      uri = URI.parse(@launch_url)

      if uri.port == uri.default_port
        host = uri.host
      else
        host = "#{uri.host}:#{uri.port}"
      end

      consumer = OAuth::Consumer.new(@consumer_key, @consumer_secret, {
              :site => "#{uri.scheme}://#{host}",
              :signature_method => "HMAC-SHA1"
      })

      path = uri.path
      path = '/' if path.empty?
      if uri.query && uri.query != ''
        CGI.parse(uri.query).each do |query_key, query_values|
          unless params[query_key]
            params[query_key] = query_values.first
          end
        end
      end
      options = {
              :scheme => 'body',
              :timestamp => @timestamp,
              :nonce => @nonce
      }
      request = consumer.create_signed_request(:post, path, nil, options, params)

      # the request is made by a html form in the user's browser, so we
      # want to revert the escapage and return the hash of post parameters ready
      # for embedding in a html view
      hash = {}
      request.body.split(/&/).each do |param|
        key, val = param.split(/=/).map { |v| CGI.unescape(v) }
        hash[key] = val
      end
      hash
    end

  end
end
