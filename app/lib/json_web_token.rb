# frozen_string_literal: true

class JsonWebToken
  def self.encode(payload)
    payload.reverse_merge!(meta)
    JWT.encode(payload, private_key, "RS256")
  end

  def self.decode(token)
    JWT.decode(token, public_key, true, algorithm: "RS256")
  end

  # Default options to be encoded in the token
  def self.meta
    {
      exp: 30.days.from_now.to_i
    }
  end

  def self.private_key
    OpenSSL::PKey::RSA.new(File.open(Rails.root.join("config", "private.pem"), "r:UTF-8"))
  end

  def self.public_key
    OpenSSL::PKey::RSA.new(File.open(Rails.root.join("config", "public.pem"), "r:UTF-8"))
  end
end
