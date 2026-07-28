# frozen_string_literal: true

FactoryBot.define do
  factory :lti_deployment do
    sequence(:issuer) { |n| "https://lms#{n}.example.com" }
    sequence(:client_id) { |n| "client-#{n}" }
    sequence(:deployment_id) { |n| "deployment-#{n}" }
    auth_login_url { "#{issuer}/api/lti/authorize_redirect" }
    access_token_url { "#{issuer}/login/oauth2/token" }
    jwks_url { "#{issuer}/api/lti/security/jwks" }
  end
end
