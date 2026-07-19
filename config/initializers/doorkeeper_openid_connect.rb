# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer do |_resource_owner, _application, request|
    # Prefer configured issuer, otherwise fall back to the current request base URL.
    ENV["DOORKEEPER_ISSUER"].presence || request&.base_url || "https://example.com"
  end

  # Configure signing key via env or fall back to RSA key files if present.
  if ENV["DOORKEEPER_JWT_SIGNING_KEY"].present?
    signing_key ENV["DOORKEEPER_JWT_SIGNING_KEY"]
  elsif File.exist?(Rails.root.join("config/private.pem"))
    signing_key File.read(Rails.root.join("config/private.pem"))
  end

  # `signing_key` also accepts an array for key rotation. The first entry is
  # the active key used to sign newly issued ID tokens; any remaining entries
  # are published in the JWKS so clients can still validate tokens signed
  # with a retired key during a rotation window.
  #
  # signing_key [
  #   File.read("config/keys/current.pem"),  # active
  #   File.read("config/keys/previous.pem"), # retired but still in JWKS
  # ]

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find_by(id: access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    resource_owner.current_sign_in_at || resource_owner.created_at
  end

  # Recommended: derive `auth_time` from the current session for `max_age`
  # enforcement. `auth_time_from_resource_owner` returns the same value for
  # every concurrent session of the same user (e.g. PC + smartphone), which
  # can let a stale session satisfy an RP's `max_age` requirement by
  # piggy-backing on a fresh login from another device.
  #
  # The block is executed in the controller's scope and receives the
  # current `session` and `request`. Return value can be a `Time`,
  # `DateTime`, or anything responding to `to_i`. Return `nil` to force
  # reauthentication.
  #
  # auth_time_from_session do |session, _request|
  #   # Example implementation: capture auth_time on the session at login,
  #   # and surface it here.
  #   session[:auth_time]
  # end

  # Advanced:
  # If you store `auth_time` in a custom authentication context record linked
  # to the access token, you can configure a block like below to derive it
  # from the access token instead of `auth_time_from_resource_owner`.
  #
  # This allows you to track `auth_time` per grant instead of per user,
  # but requires more custom implementation on your part.
  #
  # auth_time_from_access_token do |access_token|
  #   access_token.your_custom_authentication_context_record.auth_time
  # end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  select_account_for_resource_owner do |resource_owner_or_nil, return_to|
    # Example implementation:
    # if resource_owner_or_nil
    #   store_location_for resource_owner_or_nil, return_to
    # end
    # redirect_to account_select_url
  end

  subject do |resource_owner, _application|
    resource_owner.id.to_s
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Enable dynamic client registration (default false)
  # dynamic_client_registration true

  # Gate the dynamic client registration endpoint (RFC 7591 §3.1). Leave unset
  # (default `nil`) to keep the endpoint open once `dynamic_client_registration`
  # is enabled. Set a block to require authorization: it is evaluated in the
  # controller scope (so it can read `request`, `params`, `request.headers`,
  # etc.) and a falsy return rejects the request with `401 invalid_token`.
  #
  # authorize_dynamic_client_registration do
  #   # Example: require an Initial Access Token in the Authorization header.
  #   # Fail closed when the token isn't configured, so an unset env var can't
  #   # leave the endpoint open. Compare in constant time to avoid leaking the
  #   # token via timing; digesting first keeps the comparison fixed-length so
  #   # the token's length isn't leaked either.
  #   expected = ENV["DCR_INITIAL_ACCESS_TOKEN"].to_s
  #   next false if expected.empty?
  #
  #   provided = request.headers["Authorization"].to_s
  #   ActiveSupport::SecurityUtils.secure_compare(
  #     Digest::SHA256.hexdigest(provided),
  #     Digest::SHA256.hexdigest("Bearer #{expected}"),
  #   )
  # end

  # By default the `prompt` parameter (`none`, `login`, `consent`,
  # `select_account`) is only honored for OIDC requests (those carrying the
  # `openid` scope). Enable this to also honor `prompt` on non-OIDC
  # authorization requests. `max_age` stays OIDC-only, as it is defined by
  # OIDC Core.
  #
  # apply_prompt_to_non_oidc_requests true

  # End-session endpoint advertised in the discovery document
  # (`end_session_endpoint`). The block is evaluated in the controller scope;
  # return the absolute URL of your RP-initiated logout endpoint. Defaults to
  # `nil`, which omits the member from the discovery document.
  #
  # end_session_endpoint do
  #   end_session_url
  # end

  # Per-endpoint overrides for the URLs generated in the discovery document
  # (e.g. to advertise a different host or force HTTPS). The block receives the
  # current `request` and returns a hash keyed by endpoint name.
  #
  # discovery_url_options do |request|
  #   {
  #     authorization: { protocol: request.ssl? ? :https : :http },
  #   }
  # end

  # You can use your own model class if you need to extend (or even override) the default
  # Doorkeeper::OpenidConnect::Request model (e.g. to use a different database connection).
  #
  # By default Doorkeeper OpenID Connect uses:
  #
  # open_id_request_class "Doorkeeper::OpenidConnect::Request"
  #
  # Don't forget to include the OpenID Connect ORM mixin into your custom model:
  #
  #   * ::Doorkeeper::OpenidConnect::Orm::ActiveRecord::Mixins::OpenidRequest
  #
  # For example:
  #
  # open_id_request_class "MyOpenidRequest"
  #
  # class MyOpenidRequest < ApplicationRecord
  #   include ::Doorkeeper::OpenidConnect::Orm::ActiveRecord::Mixins::OpenidRequest
  # end

  # Basic profile/email claims.
  claims do
    normal_claim :email, scope: :email, response: %i[id_token user_info] do |resource_owner|
      resource_owner.email
    end

    normal_claim :name, scope: :profile, response: %i[id_token user_info] do |resource_owner|
      resource_owner.name
    end
  end
end
