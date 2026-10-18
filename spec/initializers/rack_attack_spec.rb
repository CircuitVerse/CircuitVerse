# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rack::Attack::Request do
  subject(:request) { described_class.new({}) }

  describe "#normalized_email" do
    it "downcases a normal email" do
      expect(request.normalized_email("User@Example.com")).to eq("user@example.com")
    end

    it "does not raise on invalid UTF-8 bytes" do
      bad_email = "a\xFFB@example.com"

      expect { request.normalized_email(bad_email) }.not_to raise_error
      expect(request.normalized_email(bad_email)).to be_valid_encoding
    end

    it "returns nil when the email is missing" do
      expect(request.normalized_email(nil)).to be_nil
    end
  end
end
