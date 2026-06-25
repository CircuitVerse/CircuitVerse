# frozen_string_literal: true

module Lti
  class KeyManager
    def self.private_key
      raw = Rails.application.credentials.dig(:lti, :private_key)
      raise "LTI private key missing from credentials" if raw.blank?
      OpenSSL::PKey::RSA.new(raw)
    end

    def self.public_key
      private_key.public_key
    end

    def self.jwk
      JWT::JWK.new(public_key).export.merge(use: "sig", alg: "RS256")
    end
  end
end
