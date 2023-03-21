# frozen_string_literal: true

require "rails_helper"
require "nokogiri"

RSpec.describe LtiScoreSubmission, type: :service do
  subject do
    described_class.new(
      assignment: assignment,
      lis_result_sourced_id: lis_result_sourced_id,
      score: score,
      lis_outcome_service_url: lis_outcome_service_url
    )
  end

  let(:assignment) { instance_double(Assignment, lti_consumer_key: "key", lti_shared_secret: "secret") }
  let(:lis_result_sourced_id) { "xS213j" }
  let(:score) { "0.74" }
  let(:lis_outcome_service_url) { "http://www.imsglobal.org/lis/oms1p0/pox" }
  let(:oauth_token) { double }

  describe "#call" do
    let(:oauth_token) { instance_double(OAuth::AccessToken) }

    context "when LTI score submission is successful" do
      before do
        allow(OAuth::AccessToken).to receive(:new).and_return(oauth_token)
        allow(oauth_token).to receive(:post).and_return(instance_double(Net::HTTPResponse, body: "success"))
      end

      it "returns response as true" do
        expect(subject.call).to be true
      end
    end

    context "when LTI score submission is unsuccessful" do
      before do
        allow(OAuth::AccessToken).to receive(:new).and_return(oauth_token)
        allow(oauth_token).to receive(:post).and_return(instance_double(Net::HTTPResponse, body: "failure"))
      end

      it "returns response as false" do
        expect(subject.call).to be false
      end
    end
  end

  describe "#oauth_token" do
    let(:oauth_token) { instance_double(OAuth::AccessToken) }

    it "initializes OAuth consumer" do
      allow(OAuth::Consumer).to receive(:new).with("key", "secret") { oauth_token }
      subject.send(:oauth_token)
    end

    it "returns an OAuth access token" do
      expect(subject.send(:oauth_token)).to be_a(OAuth::AccessToken)
    end
  end

  describe "#score_body" do
    it "validates XML" do
      xml = Nokogiri::XML(subject.send(:score_body).to_xml)
      xml.remove_namespaces!
      # puts xml
      expect(xml.at_xpath("//imsx_version").text).to eq("V1.0")
      expect(xml.at_xpath("//sourcedId").text).to eq(lis_result_sourced_id)
      expect(xml.at_xpath("//textString").text).to eq(score)
      expect(xml.at_xpath("//language").text).to eq("en")
    end
  end

  describe "#message_identifier" do
    it "generates 8 digits random number" do
      allow(SecureRandom).to receive(:random_number).with(9e7).and_return(1e7)
      expect(subject.send(:message_identifier)).to be_a(Integer)
      expect(subject.send(:message_identifier).to_s.length).to eq(8)
    end
  end
end
