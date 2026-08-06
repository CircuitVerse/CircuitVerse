# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::JwtValidator do
  let(:rsa_key)    { OpenSSL::PKey::RSA.generate(2048) }
  let(:jwk)        { JWT::JWK.new(rsa_key) }
  let(:kid)        { jwk.kid }
  let(:stored_key) { nil }
  let(:jwks_url)   { "https://canvas.example.com/jwks" }

  # A Struct keeps this unit isolated from the LtiDeployment model.
  let(:deployment) do
    Struct.new(:issuer, :client_id, :jwks_url, :platform_public_key, keyword_init: true).new(
      issuer: "https://canvas.example.com",
      client_id: "client-123",
      jwks_url: jwks_url,
      platform_public_key: stored_key
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
    response = instance_double(Faraday::Response, success?: true,
                                                  headers: { "content-type" => content_type },
                                                  body: { keys: keys }.to_json)
    allow(Faraday).to receive(:get).and_return(response)
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

      context "with a stored key" do
        let(:stored_key) { rsa_key.public_key.to_pem }

        it "falls back to the stored key when the JWKS fetch fails" do
          allow(Faraday).to receive(:get).and_raise(Faraday::ConnectionFailed.new("boom"))
          expect(validate).to include("sub" => "lms-user-1")
        end

        it "logs a warning when the JWKS fetch fails" do
          allow(Faraday).to receive(:get).and_raise(Faraday::TimeoutError.new("slow"))
          validate
          expect(Rails.logger).to have_received(:warn).with(/JWKS fetch failed/)
        end

        it "falls back when no JWKS key matches the kid" do
          stub_jwks(keys: [JWT::JWK.new(OpenSSL::PKey::RSA.generate(2048)).export])
          expect(validate).to include("sub" => "lms-user-1")
        end
      end

      it "raises when the JWKS fails and no stored key exists" do
        allow(Faraday).to receive(:get).and_raise(Faraday::ConnectionFailed.new("boom"))
        expect { validate }.to raise_error(described_class::ValidationError, /Could not obtain platform public key/)
      end

      context "with a blank jwks_url" do
        let(:jwks_url)   { "" }
        let(:stored_key) { rsa_key.public_key.to_pem }

        it "uses the stored key without calling the JWKS endpoint" do
          allow(Faraday).to receive(:get)
          expect(validate).to include("sub" => "lms-user-1")
          expect(Faraday).not_to have_received(:get)
        end
      end

      context "with a malformed stored key" do
        let(:stored_key) { "-----BEGIN PUBLIC KEY-----\nnot-a-key\n-----END PUBLIC KEY-----" }

        before { allow(Faraday).to receive(:get).and_raise(Faraday::ConnectionFailed.new("boom")) }

        it "raises ValidationError rather than an OpenSSL error" do
          expect { validate }.to raise_error(described_class::ValidationError, /Could not obtain platform public key/)
        end

        it "logs the invalid stored key" do
          expect { validate }.to raise_error(described_class::ValidationError)
          expect(Rails.logger).to have_received(:warn).with(/stored key invalid/)
        end
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
        stub_jwks
        2.times { validate }
        expect(Faraday).to have_received(:get).once
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
