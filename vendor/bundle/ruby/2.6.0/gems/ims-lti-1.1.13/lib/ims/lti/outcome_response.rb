module IMS::LTI
  # Class for consuming/generating LTI Outcome Responses
  #
  # Response documentation: http://www.imsglobal.org/lti/v1p1pd/ltiIMGv1p1pd.html#_Toc309649691
  #
  # Error code documentation: http://www.imsglobal.org/gws/gwsv1p0/imsgws_baseProfv1p0.html#1639667
  #
  # This class can be used by both Tool Providers and Tool Consumers. Each will
  # use it a bit differently. The Tool Provider will use it parse the result of
  # an OutcomeRequest to the Tool Consumer. A Tool Consumer will use it generate
  # proper response XML to send back to a Tool Provider
  #
  # === Tool Provider Usage
  # An OutcomeResponse will generally be created when POSTing an OutcomeRequest
  # through a configured ToolProvider. See the ToolProvider documentation for
  # typical usage.
  #
  # === Tool Consumer Usage
  # When an outcome request is sent from a Tool Provider the body of the request
  # is XML. This class parses that XML and provides a simple interface for
  # accessing the information in the request. Typical usage would be:
  #
  #    # create a new response and set the appropriate values
  #    res = IMS::LTI::OutcomeResponse.new
  #    res.message_ref_identifier = outcome_request.message_identifier
  #    res.operation = outcome_request.operation
  #    res.code_major = 'success'
  #    res.severity = 'status'
  #
  #    # set a description (optional) and other information based on the type of response
  #    if outcome_request.replace_request?
  #      res.description = "Your old score of 0 has been replaced with #{outcome_request.score}"
  #    elsif outcome_request.read_request?
  #      res.description = "You score is 50"
  #      res.score = 50
  #    elsif outcome_request.delete_request?
  #      res.description = "You score has been cleared"
  #    else
  #      res.code_major = 'unsupported'
  #      res.severity = 'status'
  #      res.description = "#{outcome_request.operation} is not supported"
  #    end
  #
  #    # the generated xml is returned to the Tool Provider
  #    res.generate_response_xml
  #
  class OutcomeResponse
    include IMS::LTI::Extensions::Base
    
    attr_accessor :request_type, :score, :message_identifier, :response_code,
            :post_response, :code_major, :severity, :description, :operation,
            :message_ref_identifier

    CODE_MAJOR_CODES = %w{success processing failure unsupported}
    SEVERITY_CODES = %w{status warning error}

    # Create a new OutcomeResponse
    #
    # @param opts [Hash] initialization hash
    def initialize(opts={})
      opts.each_pair do |key, val|
        self.send("#{key}=", val) if self.respond_to?("#{key}=")
      end
    end

    # Convenience method for creating a new OutcomeResponse from a response object
    #
    #    req = IMS::LTI::OutcomeResponse.from_post_response(response)
    def self.from_post_response(post_response)
      response = OutcomeResponse.new
      response.process_post_response(post_response)
    end
    
    def process_post_response(post_response)
      self.post_response = post_response
      self.response_code = post_response.code
      xml = post_response.body
      self.process_xml(xml)
      self
    end

    def success?
      @code_major == 'success'
    end

    def processing?
      @code_major == 'processing'
    end

    def failure?
      @code_major == 'failure'
    end

    def unsupported?
      @code_major == 'unsupported'
    end

    def has_warning?
      @severity == 'warning'
    end

    def has_error?
      @severity == 'error'
    end

    # Parse Outcome Response data from XML
    def process_xml(xml)
      doc = REXML::Document.new xml
      @message_identifier = doc.text("//imsx_statusInfo/imsx_messageIdentifier").to_s
      @code_major = doc.text("//imsx_statusInfo/imsx_codeMajor")
      @code_major.downcase! if @code_major
      @severity = doc.text("//imsx_statusInfo/imsx_severity")
      @severity.downcase! if @severity
      @description = doc.text("//imsx_statusInfo/imsx_description")
      @description = @description.to_s if @description
      @message_ref_identifier = doc.text("//imsx_statusInfo/imsx_messageRefIdentifier")
      @operation = doc.text("//imsx_statusInfo/imsx_operationRefIdentifier")
      @score = doc.text("//readResultResponse//resultScore/textString")
      @score = @score.to_s if @score
    end

    # Generate XML based on the current configuration
    # @return [String] The response xml
    def generate_response_xml
      builder = Builder::XmlMarkup.new
      builder.instruct!

      builder.imsx_POXEnvelopeResponse("xmlns" => "http://www.imsglobal.org/services/ltiv1p1/xsd/imsoms_v1p0") do |env|
        env.imsx_POXHeader do |header|
          header.imsx_POXResponseHeaderInfo do |info|
            info.imsx_version "V1.0"
            info.imsx_messageIdentifier @message_identifier || IMS::LTI::generate_identifier
            info.imsx_statusInfo do |status|
              status.imsx_codeMajor @code_major
              status.imsx_severity @severity
              status.imsx_description @description
              status.imsx_messageRefIdentifier @message_ref_identifier
              status.imsx_operationRefIdentifier @operation
            end
          end
        end #/header
        env.imsx_POXBody do |body|
          unless unsupported?
            if @operation == OutcomeRequest::READ_REQUEST
              body.tag!(@operation + 'Response') do |request|
                request.result do |res|
                  res.resultScore do |res_score|
                    res_score.language "en" # 'en' represents the format of the number
                    res_score.textString @score.to_s
                  end
                end #/result
              end
            else
              body.tag!(@operation + 'Response')
            end #/operationResponse
          end
        end #/body
      end
    end

  end
end
