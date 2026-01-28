require 'rails_helper'

RSpec.describe "Rack::Attack", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    # Enable Rack::Attack for this test
    Rack::Attack.enabled = true
    Rack::Attack.reset!
  end

  after do
    Rack::Attack.enabled = false
  end

  describe "Throttling logins" do
    let(:headers) { { "REMOTE_ADDR" => "1.2.3.4" } }

    context "when user params are missing" do
      it "does not raise NoMethodError" do
        # This triggers the NoMethodError: undefined method `[]' for nil
        # req.params["user"]["email"] where params["user"] is nil
        expect {
          post "/users/sign_in", params: {}, headers: headers
        }.not_to raise_error
      end

      it "does not raise error with empty user params" do
        expect {
          post "/users/sign_in", params: { user: {} }, headers: headers
        }.not_to raise_error
      end
    end

    context "when user params are present" do
      it "throttles after limit is reached (IP)" do
        # Limit is 5 per 20 seconds
        5.times do
          post "/users/sign_in", params: { user: { email: "test@example.com" } }, headers: headers
          expect(response.status).not_to eq(429)
        end

        post "/users/sign_in", params: { user: { email: "test@example.com" } }, headers: headers
        expect(response.status).to eq(429)
      end
    end
  end

  describe "Throttling API logins" do
    let(:headers) { { "REMOTE_ADDR" => "1.2.3.4", "CONTENT_TYPE" => "application/json" } }

    context "when json params are missing/malformed" do
      it "does not raise error" do
         expect {
            post "/api/v1/auth/login", params: "{}", headers: headers
         }.not_to raise_error
      end
    end
  end
end
