# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::JwtValidator do
  let(:rsa_key)    { OpenSSL::PKey::RSA.generate(2048) }
  let(:jwk)        { JWT::JWK.new(rsa_key) }
  let(:kid)        { jwk.kid }
  let(:jwks_url)   { "https://canvas.example.com/jwks" }

  # A Struct keeps this unit isolated from the LtiDeployment model.
  let(:deployment) do
    Struct.new(:issuer, :client_id, :jwks_url, keyword_init: true).new(
      issuer: "https://canvas.example.com",
      client_id: "client-123",
      jwks_url: jwks_url
    )
  end

  def claims(overrides = {})
    {
      "sub" => "lms-user-1", "iss" => deployment.issuer, "aud" => deployment.client_id,
      "nonce" => "nonce-1", "email" => "teacher@example.com", "exp" => 5.minutes.from_now.to_i
    }.merge(overrides)
  end

  def token(payload = claims, key: rsa_key, alg: "RS256", header: { kid: kid })
    JWT.encode(payload, key, alg, header)
  end

  def stub_jwks(keys: [jwk.export], content_type: "application/json")
    response = instance_double(
      HTTP::Response,
      status: instance_double(HTTP::Response::Status, success?: true),
      content_type: instance_double(HTTP::ContentType, mime_type: content_type),
      body: { keys: keys }.to_json
    )
    client = instance_double(HTTP::Client, get: response)
    allow(HTTP).to receive(:timeout).and_return(client)
    client
  end

  def stub_jwks_failure(error = HTTP::ConnectionError.new("boom"))
    client = instance_double(HTTP::Client)
    allow(HTTP).to receive(:timeout).and_return(client)
    allow(client).to receive(:get).and_raise(error)
    client
  end

  def validate(jwt = token, nonce: "nonce-1")
    described_class.validate!(jwt, deployment: deployment, nonce: nonce)
  end

  describe ".validate!" do
    context "with a valid token" do
      before { stub_jwks }

      it "returns the payload" do
        expect(validate).to include("sub" => "lms-user-1", "email" => "teacher@example.com")
      end

      it "succeeds without the optional email claim" do
        expect(validate(token(claims.except("email")))).to include("sub" => "lms-user-1")
      end
    end

    context "signature verification" do
      before { stub_jwks }

      it "rejects a token signed by a different key" do
        expect { validate(token(claims, key: OpenSSL::PKey::RSA.generate(2048))) }
          .to raise_error(described_class::ValidationError)
      end

      it "rejects an HS256 (algorithm-confusion) token" do
        expect { validate(token(claims, key: rsa_key.public_key.to_pem, alg: "HS256")) }
          .to raise_error(described_class::ValidationError)
      end

      it "rejects an unsigned (alg: none) token" do
        expect { validate(token(claims, key: nil, alg: "none")) }
          .to raise_error(described_class::ValidationError)
      end
    end

    context "claim and nonce verification" do
      before { stub_jwks }

      it "rejects a mismatched issuer" do
        expect { validate(token(claims("iss" => "https://evil.test"))) }
          .to raise_error(described_class::ValidationError)
      end

      it "rejects a mismatched audience" do
        expect { validate(token(claims("aud" => "other"))) }
          .to raise_error(described_class::ValidationError)
      end

      it "rejects an expired token" do
        expect { validate(token(claims("exp" => 1.hour.ago.to_i))) }
          .to raise_error(described_class::ValidationError)
      end

      it "accepts a token that expired within the clock-skew leeway" do
        stub_jwks
        expect(validate(token(claims("exp" => 10.seconds.ago.to_i))))
          .to include("sub" => "lms-user-1")
      end

      it "rejects a token missing the sub claim" do
        expect { validate(token(claims.except("sub"))) }
          .to raise_error(described_class::ValidationError, /Missing sub/)
      end

      it "rejects a non-string sub claim" do
        expect { validate(token(claims("sub" => { "id" => "lms-user-1" }))) }
          .to raise_error(described_class::ValidationError, /Missing sub/)
      end

      it "rejects a missing or non-string token" do
        [nil, 123].each do |bad_token|
          expect { validate(bad_token) }
            .to raise_error(described_class::ValidationError, /Missing id_token/)
        end
      end

      it "rejects a blank expected nonce" do
        expect { validate(nonce: "") }.to raise_error(described_class::ValidationError, /Missing nonce/)
      end

      it "rejects a mismatched nonce" do
        expect { validate(token(claims("nonce" => "other"))) }
          .to raise_error(described_class::ValidationError, /Nonce mismatch/)
      end
    end

    context "multi-audience azp handling" do
      before { stub_jwks }

      it "accepts an array aud when azp names our client_id" do
        expect(validate(token(claims("aud" => [deployment.client_id, "x"], "azp" => deployment.client_id))))
          .to include("sub" => "lms-user-1")
      end

      it "rejects an array aud when azp does not match" do
        expect { validate(token(claims("aud" => [deployment.client_id, "x"], "azp" => "x"))) }
          .to raise_error(described_class::ValidationError, /azp does not match/)
      end
    end

    context "platform key resolution" do
      before { allow(Rails.logger).to receive(:warn) }

      it "raises when the JWKS fetch fails" do
        stub_jwks_failure
        expect { validate }.to raise_error(described_class::ValidationError, /Could not obtain platform public key/)
      end

      it "logs a warning when the JWKS fetch fails" do
        stub_jwks_failure(HTTP::TimeoutError.new("slow"))
        expect { validate }.to raise_error(described_class::ValidationError)
        expect(Rails.logger).to have_received(:warn).with(/JWKS fetch failed/)
      end

      it "raises when no JWKS key matches the kid" do
        stub_jwks(keys: [JWT::JWK.new(OpenSSL::PKey::RSA.generate(2048)).export])
        expect { validate }.to raise_error(described_class::ValidationError, /Could not obtain platform public key/)
      end

      it "raises when the key set is not served as json" do
        stub_jwks(content_type: "text/html")
        expect { validate }.to raise_error(described_class::ValidationError)
      end
    end

    context "when the jwks_url cannot be fetched safely" do
      shared_examples "refuses to call out" do
        it "raises without reaching the platform" do
          client = stub_jwks
          expect { validate }.to raise_error(described_class::ValidationError,
                                             /Could not obtain platform public key/)
          expect(client).not_to have_received(:get)
        end
      end

      context "with a blank url" do
        let(:jwks_url) { "" }

        it_behaves_like "refuses to call out"
      end

      context "with a non-http url" do
        let(:jwks_url) { "javascript:alert(1)" }

        it_behaves_like "refuses to call out"
      end

      context "with a plain http url in production" do
        let(:jwks_url) { "http://canvas.example.com/jwks" }

        before { allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) }

        it_behaves_like "refuses to call out"
      end
    end

    context "JWKS caching" do
      around do |example|
        original = Rails.cache
        Rails.cache = ActiveSupport::Cache::MemoryStore.new
        example.run
      ensure
        Rails.cache = original
      end

      it "reuses the cached key set on a second launch" do
        client = stub_jwks
        2.times { validate }
        expect(client).to have_received(:get).once
      end

      it "picks up a rotated key without waiting for the cache to expire" do
        stub_jwks(keys: [JWT::JWK.new(OpenSSL::PKey::RSA.generate(2048)).export])
        expect { validate }.to raise_error(described_class::ValidationError)

        stub_jwks
        expect(validate).to include("sub" => "lms-user-1")
      end
    end
  end
end
