module IMS::LTI
  # Class for consuming/generating LTI Outcome Requests
  #
  # Outcome Request documentation: http://www.imsglobal.org/lti/v1p1pd/ltiIMGv1p1pd.html#_Toc309649691
  #
  # This class can be used by both Tool Providers and Tool Consumers. Each will
  # use it a bit differently. The Tool Provider will use it to POST an OAuth-signed
  # request to a TC. A Tool Consumer will use it to parse such a request from a TP.
  #
  # === Tool Provider Usage
  # An OutcomeRequest will generally be created through a configured ToolProvider
  # object. See the ToolProvider documentation.
  #
  # === Tool Consumer Usage
  # When an outcome request is sent from a TP the body of the request is XML.
  # This class parses that XML and provides a simple interface for accessing the
  # information in the request. Typical usage would be:
  #
  #    # create an OutcomeRequest from the request object
  #    req = IMS::LTI::OutcomeRequest.from_post_request(request)
  #
  #    # access the source id to identify the user who's grade you'd like to access
  #    req.lis_result_sourcedid
  #
  #    # process the request
  #    if req.replace_request?
  #      # set a new score for the user
  #    elsif req.read_request?
  #      # return the score for the user
  #    elsif req.delete_request?
  #      # clear the score for the user
  #    else
  #      # return an unsupported OutcomeResponse
  #    end
  class OutcomeRequest < ToolBase
    include IMS::LTI::Extensions::Base

    REPLACE_REQUEST = 'replaceResult'
    DELETE_REQUEST = 'deleteResult'
    READ_REQUEST = 'readResult'

    attr_accessor :operation, :score, :outcome_response, :message_identifier,
                  :lis_outcome_service_url, :lis_result_sourcedid,
                  :consumer_key, :consumer_secret, :post_request

    # Create a new OutcomeRequest
    #
    # @param opts [Hash] initialization hash
    def initialize(opts={})
      opts.each_pair do |key, val|
        self.send("#{key}=", val) if self.respond_to?("#{key}=")
      end
    end

    # Convenience method for creating a new OutcomeRequest from a request object
    #
    #    req = IMS::LTI::OutcomeRequest.from_post_request(request)
    def self.from_post_request(post_request)
      request = OutcomeRequest.new
      request.process_post_request(post_request)
    end

    def process_post_request(post_request)
      self.post_request = post_request
      if post_request.body.respond_to?(:read)
        xml = post_request.body.read
        post_request.body.rewind
      else
        xml = post_request.body
      end
      self.process_xml(xml)
      self
    end

    # POSTs the given score to the Tool Consumer with a replaceResult
    #
    # @return [OutcomeResponse] The response from the Tool Consumer
    def post_replace_result!(score)
      @operation = REPLACE_REQUEST
      @score = score
      post_outcome_request
    end

    # POSTs a deleteResult to the Tool Consumer
    #
    # @return [OutcomeResponse] The response from the Tool Consumer
    def post_delete_result!
      @operation = DELETE_REQUEST
      post_outcome_request
    end

    # POSTs a readResult to the Tool Consumer
    #
    # @return [OutcomeResponse] The response from the Tool Consumer
    def post_read_result!
      @operation = READ_REQUEST
      post_outcome_request
    end

    # Check whether this request is a replaceResult request
    def replace_request?
      @operation == REPLACE_REQUEST
    end

    # Check whether this request is a deleteResult request
    def delete_request?
      @operation == DELETE_REQUEST
    end

    # Check whether this request is a readResult request
    def read_request?
      @operation == READ_REQUEST
    end

    # Check whether the last outcome POST was successful
    def outcome_post_successful?
      @outcome_response && @outcome_response.success?
    end

    # POST an OAuth signed request to the Tool Consumer
    #
    # @return [OutcomeResponse] The response from the Tool Consumer
    def post_outcome_request
      raise IMS::LTI::InvalidLTIConfigError, "" unless has_required_attributes?

      res = post_service_request(@lis_outcome_service_url,
                                 'application/xml',
                                 generate_request_xml)

      @outcome_response = extend_outcome_response(OutcomeResponse.new)
      @outcome_response.process_post_response(res)
    end

    # Parse Outcome Request data from XML
    def process_xml(xml)
      doc = REXML::Document.new xml
      @message_identifier = doc.text("//imsx_POXRequestHeaderInfo/imsx_messageIdentifier")
      @lis_result_sourcedid = doc.text("//resultRecord/sourcedGUID/sourcedId")

      if REXML::XPath.first(doc, "//deleteResultRequest")
        @operation = DELETE_REQUEST
      elsif REXML::XPath.first(doc, "//readResultRequest")
        @operation = READ_REQUEST
      elsif REXML::XPath.first(doc, "//replaceResultRequest")
        @operation = REPLACE_REQUEST
        @score = doc.get_text("//resultRecord/result/resultScore/textString")
      end
      extention_process_xml(doc)
    end

    def generate_request_xml
      raise IMS::LTI::InvalidLTIConfigError, "`@operation` and `@lis_result_sourcedid` are required" unless has_request_xml_attributes?
      builder = Builder::XmlMarkup.new #(:indent=>2)
      builder.instruct!

      builder.imsx_POXEnvelopeRequest("xmlns" => "http://www.imsglobal.org/services/ltiv1p1/xsd/imsoms_v1p0") do |env|
        env.imsx_POXHeader do |header|
          header.imsx_POXRequestHeaderInfo do |info|
            info.imsx_version "V1.0"
            info.imsx_messageIdentifier @message_identifier || IMS::LTI::generate_identifier
          end
        end
        env.imsx_POXBody do |body|
          body.tag!(@operation + 'Request') do |request|
            request.resultRecord do |record|
              record.sourcedGUID do |guid|
                guid.sourcedId @lis_result_sourcedid
              end
              results(record)
            end
            submission_details(request)
          end
        end
      end
    end

    private

    def extention_process_xml(doc)
    end

    def has_result_data?
      !!score
    end

    def has_details_data?
      false
    end

    def results(node)
      return unless has_result_data?

      node.result do |res|
        result_values(res)
      end
    end

    def submission_details(request)
      return unless has_details_data?
      request.submissionDetails do |record|
        details(record)
      end
    end

    def details(record)
    end

    def result_values(node)
      if score
        node.resultScore do |res_score|
          res_score.language "en" # 'en' represents the format of the number
          res_score.textString score.to_s
        end
      end
    end

    def has_required_attributes?
      @consumer_key && @consumer_secret && @lis_outcome_service_url && @lis_result_sourcedid && @operation
    end

    def has_request_xml_attributes?
      @operation && @lis_result_sourcedid
    end
  end
end
