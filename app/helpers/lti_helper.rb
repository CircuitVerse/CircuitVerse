module LtiHelper
  def lms_integration_tutorial
    return "https://www.example.com" # link to the tutorial of linking cv assignment with LMS
  end

  def lti_score_submit(lis_result_sourcedid, score)
    # build the xml for score
    score_body =  Nokogiri::XML::Builder.new do |xml|
      xml.imsx_POXEnvelopeRequest(xmlns: "http://www.imsglobal.org/lis/oms1p0/pox") do
        xml.imsx_POXHeader do
          xml.imsx_POXRequestHeaderInfo do
            xml.imsx_version "V1.0"
            xml.imsx_messageIdentifier (SecureRandom.random_number(9e7) + 1e7).to_i # generating a 8 digit random number like 12341234
          end
        end
        xml.imsx_POXBody do
          xml.replaceResultRequest do
            xml.resultRecord do
              xml.sourcedGUID do
                xml.sourcedId lis_result_sourcedid
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
    # post the xml to lms
    @assignment = Assignment.find_by(lti_consumer_key: session[:oauth_consumer_key])
    consumer = OAuth::Consumer.new(session[:oauth_consumer_key], @assignment.lti_shared_secret)
    token = OAuth::AccessToken.new(consumer)
    response = token.post(session[:lis_outcome_service_url], score_body.to_xml, 'Content-Type' => 'application/xml')
    # response handling
    if response.body.match(/\bsuccess\b/)
      puts "score submitted"
    else
      puts "score submission failed"
    end
  end
end
