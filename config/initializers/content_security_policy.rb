Rails.application.config.content_security_policy_nonce_generator = -> _request { SecureRandom.base64(16) }
Rails.application.config.content_security_policy do |policy|
    policy.script_src :self, :https, :unsafe_eval
end