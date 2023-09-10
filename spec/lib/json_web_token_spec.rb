# frozen_string_literal: true

require "rails_helper"
require "jwt"
require "openssl"

RSpec.describe JsonWebToken do
  # Generate a fresh RSA key pair for tests
  let(:rsa_private) { OpenSSL::PKey::RSA.generate(2048) }
  let(:sample_payload) { { user_id: 1 } }
  let(:rsa_public) { rsa_private.public_key }

  before do
    # Stub the private_key and public_key methods to return the test keys
    allow(described_class).to receive(:private_key).and_return(rsa_private)
    allow(described_class).to receive(:public_key).and_return(rsa_public)
  end

  describe ".encode" do
    it "returns a JWT token string" do
      token = described_class.encode(sample_payload)
      expect(token).to be_a(String)
    end

    it "contains rememberme key set to true by default" do
      token = described_class.encode(sample_payload)
      decoded_payload = JWT.decode(token, nil, false).first
      expect(decoded_payload["rememberme"]).to be_truthy
    end
  end

  describe ".decode" do
    let(:token) { described_class.encode(sample_payload) }

    it "decodes a JWT token" do
      decoded_payload = described_class.decode(token).first
      expect(decoded_payload["user_id"]).to eq(sample_payload[:user_id])
    end
  end

  describe ".meta" do
    context "when remember_me is true" do
      it "returns expiration time of 2 weeks from now" do
        allow(Time).to receive(:now).and_return(Time.zone.parse("2023-01-01 00:00:00"))
        expect(described_class.meta(true)[:exp]).to eq(2.weeks.from_now.to_i)
      end
    end

    context "when remember_me is false" do
      it "returns expiration time of 1 day from now" do
        allow(Time).to receive(:now).and_return(Time.zone.parse("2023-01-01 00:00:00"))
        expect(described_class.meta(false)[:exp]).to eq(1.day.from_now.to_i)
      end
    end
  end

  describe ".private_key" do
    it "returns a RSA private key" do
      expect(described_class.private_key).to be_an_instance_of(OpenSSL::PKey::RSA)
    end
  end

  describe ".public_key" do
    it "returns a RSA public key" do
      expect(described_class.public_key).to be_an_instance_of(OpenSSL::PKey::RSA)
    end
  end
end
