# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::AccessToken do
  include ActiveSupport::Testing::TimeHelpers

  let(:signing_key) { OpenSSL::PKey::RSA.generate(2048) }
  let(:deployment)  { FactoryBot.create(:lti_deployment) }
  let(:scopes)      { ["https://purl.imsglobal.org/spec/lti-ags/scope/score"] }
  let(:posted)      { {} }

  around do |example|
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
  ensure
    Rails.cache = original
  end

  def stub_token(body: { access_token: "tok-1", expires_in: 3600 }, success: true, status: 200)
    response = instance_double(HTTP::Response, body: body.to_json,
                                               status: instance_double(HTTP::Response::Status,
                                                                       success?: success, to_s: status.to_s))
    client = instance_double(HTTP::Client)
    allow(HTTP).to receive(:timeout).and_return(client)
    allow(client).to receive(:post) do |_url, options|
      posted.merge!(options[:form])
      response
    end
    client
  end

  def fetch(scope_list = scopes)
    described_class.fetch(deployment, scope_list, signing_key: signing_key)
  end

  describe ".fetch" do
    it "returns the access token from the platform" do
      stub_token
      expect(fetch).to eq("tok-1")
    end

    it "posts a client_credentials grant to the platform token endpoint" do
      client = stub_token
      fetch

      expect(client).to have_received(:post).with(deployment.access_token_url, any_args)
      expect(posted).to include(grant_type: "client_credentials",
                                client_assertion_type: described_class::ASSERTION_TYPE,
                                scope: scopes.first)
    end

    it "signs the assertion with claims the platform can verify" do
      stub_token
      fetch

      payload, header = JWT.decode(posted[:client_assertion], signing_key.public_key, true,
                                   algorithms: ["RS256"])

      expect(payload).to include("iss" => deployment.client_id, "sub" => deployment.client_id,
                                 "aud" => deployment.access_token_url)
      expect(payload["jti"]).to be_present
      expect(header["kid"]).to be_present
    end

    it "names the key by the kid the tool publishes in its jwks" do
      allow(Lti::KeyManager).to receive(:private_key).and_return(signing_key)
      stub_token
      fetch

      _payload, header = JWT.decode(posted[:client_assertion], signing_key.public_key, true,
                                    algorithms: ["RS256"])

      expect(header["kid"]).to eq(Lti::KeyManager.public_jwk[:kid])
    end

    it "reuses a cached token instead of asking again" do
      client = stub_token
      2.times { fetch }
      expect(client).to have_received(:post).once
    end

    it "keys the cache on the scope set regardless of order" do
      client = stub_token
      fetch(%w[b a])
      fetch(%w[a b])
      expect(client).to have_received(:post).once
    end

    it "asks again for a different scope set" do
      client = stub_token
      fetch(%w[a])
      fetch(%w[b])
      expect(client).to have_received(:post).twice
    end

    it "treats a repeated scope as the same scope set" do
      client = stub_token
      fetch(%w[a])
      fetch(%w[a a])
      expect(client).to have_received(:post).once
    end

    it "refreshes once the cached token has expired" do
      client = stub_token(body: { access_token: "tok-1", expires_in: 60 })
      fetch
      travel_to(31.seconds.from_now) { fetch }

      expect(client).to have_received(:post).twice
    end

    it "does not cache a token that expires within the refresh leeway" do
      client = stub_token(body: { access_token: "tok-1", expires_in: 10 })
      2.times { fetch }
      expect(client).to have_received(:post).twice
    end

    it "raises when the platform rejects the assertion" do
      stub_token(body: { error: "invalid_client" }, success: false, status: 401)
      expect { fetch }.to raise_error(described_class::Error, /401/)
    end

    it "does not cache a token the platform gave no lifetime for" do
      client = stub_token(body: { access_token: "tok-1" })
      2.times { fetch }

      expect(client).to have_received(:post).twice
    end

    it "raises when the response carries no access token" do
      stub_token(body: { expires_in: 3600 })
      expect { fetch }.to raise_error(described_class::Error)
    end

    it "raises rather than caching a blank access token" do
      stub_token(body: { access_token: "", expires_in: 3600 })
      expect { fetch }.to raise_error(described_class::Error, /access_token/)
      expect(Rails.cache.read(["lti/access_token", deployment.id, scopes.first])).to be_nil
    end

    it "raises when the access token is not a string" do
      stub_token(body: { access_token: { value: "tok-1" }, expires_in: 3600 })
      expect { fetch }.to raise_error(described_class::Error, /access_token/)
    end

    it "raises when the platform is unreachable" do
      client = instance_double(HTTP::Client)
      allow(HTTP).to receive(:timeout).and_return(client)
      allow(client).to receive(:post).and_raise(HTTP::ConnectionError, "connection refused")

      expect { fetch }.to raise_error(described_class::Error, /refused/)
    end
  end
end
