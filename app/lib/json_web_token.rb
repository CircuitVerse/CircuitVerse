# frozen_string_literal: true

class JsonWebToken
  # @param [Hash] payload
  # @return [String] encoded string
  def self.encode(payload)
    payload.reverse_merge!(meta)
    JWT.encode(payload, private_key, "RS256")
  end

  # @param [String] token The JSON Web Token to decode.
  # @return [Array] An array containing the decoded payload and header.
  def self.decode(token)
    JWT.decode(token, public_key, true, algorithm: "RS256")
  end

  # Default options to be encoded in the token
  # @return [Hash]
  def self.meta
    {
      exp: 30.days.from_now.to_i
    }
  end

  # @return [OpenSSL::PKey::RSA]
  def self.private_key
    OpenSSL::PKey::RSA.new(File.open(Rails.root.join("config", "private.pem"), "r:UTF-8"))
  end

  # @return [OpenSSL::PKey::RSA]
  def self.public_key
    OpenSSL::PKey::RSA.new(File.open(Rails.root.join("config", "public.pem"), "r:UTF-8"))
  end
end
