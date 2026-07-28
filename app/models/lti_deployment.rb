# frozen_string_literal: true

class LtiDeployment < ApplicationRecord
  validates :issuer, :client_id, :deployment_id,
            :auth_login_url, :access_token_url, :jwks_url,
            presence: true

  validates :deployment_id, uniqueness: { scope: %i[issuer client_id] }
end
