# frozen_string_literal: true

class LtiDeployment < ApplicationRecord
  has_many :assignments

  validates :platform_id,
            :deployment_id,
            :client_id,
            :issuer,
            :jwks_url,
            :access_token_url,
            :auth_login_url, presence: true

  validates :deployment_id, uniqueness: { scope: :platform_id }
end
