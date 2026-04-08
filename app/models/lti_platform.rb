# frozen_string_literal: true

class LtiPlatform < ApplicationRecord
  validates :issuer, :client_id, :auth_url,
            :token_url, :jwks_url, presence: true
  validates :issuer, uniqueness: { scope: :client_id,
    message: "already registered for this client_id" }

  def self.find_by_launch_params(iss, client_id)
    find_by(issuer: iss, client_id: client_id)
  end
end
