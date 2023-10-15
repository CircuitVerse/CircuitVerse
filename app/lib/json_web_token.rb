# frozen_string_literal: true

class JsonWebToken
  def self.encode(payload)
    payload[:rememberme] ||= true
    payload.reverse_merge!(meta(payload[:rememberme]))
    JWT.encode(payload, private_key, "RS256")
  end

  def self.decode(token)
    JWT.decode(token, public_key, true, algorithm: "RS256")
  end

  def self.meta(remember_me)
    {
      exp: expiration_time(remember_me).to_i
    }
  end

  # if remember_me is not defined expiration time is set 14 days by default
  def self.expiration_time(remember_me)
    if remember_me
      2.weeks.from_now
    else
      1.day.from_now
    end
  end

  def self.private_key
    OpenSSL::PKey::RSA.new(File.open(Rails.root.join("config", "private.pem"), "r:UTF-8"))
  end

  def self.public_key
    OpenSSL::PKey::RSA.new(File.open(Rails.root.join("config", "public.pem"), "r:UTF-8"))
  end
end
