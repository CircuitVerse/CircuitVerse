# frozen_string_literal: true

require "rails_helper"

describe Lti::KeyManager do
  before { described_class.reset! }

  after { described_class.reset! }

  describe ".private_key" do
    it "returns an RSA private key" do
      expect(described_class.private_key).to be_an(OpenSSL::PKey::RSA)
      expect(described_class.private_key.private?).to be(true)
    end

    it "memoizes the key" do
      expect(described_class.private_key).to equal(described_class.private_key)
    end

    it "uses the key from the environment when provided" do
      pem = OpenSSL::PKey::RSA.new(2048).to_pem
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("LTI_TOOL_PRIVATE_KEY", nil).and_return(pem)

      expect(described_class.private_key.to_pem).to eq(pem)
    end
  end

  describe ".public_jwk" do
    it "returns an RSA signing key with a key id" do
      jwk = described_class.public_jwk
      expect(jwk[:kty].to_s).to eq("RSA")
      expect(jwk[:use]).to eq("sig")
      expect(jwk[:alg]).to eq("RS256")
      expect(jwk[:kid]).to be_present
    end

    it "does not expose private key material" do
      expect(described_class.public_jwk).not_to have_key(:d)
    end

    it "keeps the key id stable across calls" do
      first_kid = described_class.public_jwk[:kid]
      second_kid = described_class.public_jwk[:kid]
      expect(first_kid).to eq(second_kid)
    end
  end
end
