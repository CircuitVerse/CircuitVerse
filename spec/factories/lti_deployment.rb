# frozen_string_literal: true

FactoryBot.define do
  factory :lti_deployment do
    sequence(:platform_id) { |n| "https://canvas#{n}.example.com" }
    sequence(:deployment_id) { |n| "deploy-#{n}" }
    sequence(:client_id) { |n| "client-#{n}" }
    sequence(:issuer) { |n| "https://canvas#{n}.example.com" }
    jwks_url { "#{platform_id}/api/lti/security/jwks" }
    access_token_url { "#{platform_id}/login/oauth2/token" }
    auth_login_url { "#{platform_id}/api/lti/authorize_redirect" }
    platform_public_key { nil }
  end
end
