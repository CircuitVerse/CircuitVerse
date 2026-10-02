# frozen_string_literal: true

# Validate production secrets at boot. Missing secrets are logged as
# warnings instead of raised so a misconfigured deploy stays up while
# the problem is visible in the logs.
if Rails.env.production?
  production_secrets = {
    "AWS_ACCESS_KEY_ID_SES" => "email delivery via Amazon SES",
    "AWS_SECRET_ACCESS_KEY_SES" => "email delivery via Amazon SES",
    "VAPID_PUBLIC_KEY" => "web push notifications",
    "VAPID_PRIVATE_KEY" => "web push notifications"
  }

  production_secrets.each do |key, feature|
    next if ENV[key].present?

    Rails.logger.warn("[secrets] #{key} is not set; #{feature} will not work.")
  end
end
