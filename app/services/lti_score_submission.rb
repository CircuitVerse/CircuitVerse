# frozen_string_literal: true

class LtiScoreSubmission
  def initialize(assignment:, lis_result_sourced_id:, score:, lis_outcome_service_url:)
    @assignment = assignment
    @lis_result_sourced_id = lis_result_sourced_id
    @score = score
    @lis_outcome_service_url = lis_outcome_service_url
  end

  def call
    response = oauth_token.post(
      lis_outcome_service_url,
      score_body.to_xml, "Content-Type" => "application/xml"
    )
    if /\bsuccess\b/.match?(response.body)
      true # grade submission success
    else
      false # grade submission failed
    end
  end

  private

    attr_reader :lis_result_sourced_id, :assignment, :score, :lis_outcome_service_url

    def oauth_token
      consumer = OAuth::Consumer.new(assignment.lti_consumer_key, assignment.lti_shared_secret)
      OAuth::AccessToken.new(consumer)
    end

    def score_body
      Nokogiri::XML::Builder.new do |xml|
        xml.imsx_POXEnvelopeRequest(xmlns: "http://www.imsglobal.org/lis/oms1p0/pox") do
          xml.imsx_POXHeader do
            xml.imsx_POXRequestHeaderInfo do
              xml.imsx_version "V1.0"
              xml.imsx_messageIdentifier message_identifier
            end
          end
          xml.imsx_POXBody do
            xml.replaceResultRequest do
              xml.resultRecord do
                xml.sourcedGUID do
                  xml.sourcedId lis_result_sourced_id
                end
                xml.result do
                  xml.resultScore do
                    xml.language "en"
                    xml.textString score
                  end
                end
              end
            end
          end
        end
      end
    end

    def message_identifier
      # generating a 8 digit random number like 12341234
      (SecureRandom.random_number(9e7) + 1e7).to_i
    end
end
