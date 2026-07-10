# frozen_string_literal: true

require "rails_helper"

describe LtiController, type: :request do
  let(:private_key)    { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key_pem) { private_key.public_key.to_pem }
  let!(:deployment)    { FactoryBot.create(:lti_deployment, platform_public_key: public_key_pem) }

  before { Flipper.enable(:lti_advantage) }
  after  { Flipper.disable(:lti_advantage) }

  def id_token(overrides = {})
    now = Time.current.to_i
    payload = {
      "iss" => deployment.issuer,
      "aud" => deployment.client_id,
      LtiController::DEPLOYMENT_ID_CLAIM => deployment.deployment_id,
      "sub" => SecureRandom.uuid,
      "nonce" => "test-nonce",
      "iat" => now,
      "exp" => now + 3600,
      "email" => "student@example.com",
      "name" => "Test Student"
    }.merge(overrides)
    JWT.encode(payload, private_key, "RS256")
  end

  # Performs the OIDC login initiation and returns the signed state and nonce
  # from the resulting redirect, mirroring what a real platform echoes back on
  # the launch (state as-is, nonce inside the id_token).
  def complete_oidc_login
    post lti_login_path, params: {
      iss: deployment.issuer,
      client_id: deployment.client_id,
      login_hint: "hint_abc",
      target_link_uri: "http://www.example.com/lti/launch"
    }
    redirect = Rack::Utils.parse_query(URI(response.location).query)
    { state: redirect["state"], nonce: redirect["nonce"] }
  end

  describe "GET /lti/jwks" do
    before do
      allow(Lti::KeyManager).to receive(:jwk).and_return(
        { kty: "RSA", use: "sig", alg: "RS256", kid: "test-kid" }
      )
    end

    it "returns the tool public JWK set" do
      get lti_jwks_path
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["keys"]).to be_an(Array)
      expect(body["keys"].first["kty"]).to eq("RSA")
    end
  end

  describe "GET /lti/config" do
    it "returns the tool configuration JSON" do
      get lti_config_path
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["title"]).to eq("CircuitVerse")
      expect(body).to have_key("oidc_initiation_url")
      expect(body).to have_key("target_link_uri")
    end
  end

  describe "POST /lti/login (OIDC initiation)" do
    let(:login_params) do
      {
        iss: deployment.issuer,
        client_id: deployment.client_id,
        login_hint: "hint_abc",
        target_link_uri: "http://www.example.com/lti/launch"
      }
    end

    context "with a registered deployment" do
      it "redirects to the Canvas OIDC authorization endpoint" do
        post lti_login_path, params: login_params
        expect(response).to redirect_to(/#{Regexp.escape(deployment.auth_login_url)}/)
      end

      it "supports GET-based OIDC login initiation" do
        get lti_login_path, params: login_params
        expect(response).to redirect_to(/#{Regexp.escape(deployment.auth_login_url)}/)
      end

      it "requests a form_post id_token without an interactive prompt" do
        post lti_login_path, params: login_params
        redirect_params = Rack::Utils.parse_query(URI(response.location).query)
        expect(redirect_params["response_mode"]).to eq("form_post")
        expect(redirect_params["prompt"]).to eq("none")
      end

      it "returns a signed state and nonce in the redirect" do
        post lti_login_path, params: login_params
        redirect = Rack::Utils.parse_query(URI(response.location).query)
        expect(redirect["state"]).to be_present
        expect(redirect["nonce"]).to be_present
        # state is signed, not raw random data, so it round-trips through the verifier
        verifier = Rails.application.message_verifier(LtiController::LTI_STATE_PURPOSE)
        data = verifier.verified(redirect["state"], purpose: LtiController::LTI_STATE_PURPOSE)
        expect(data["nonce"]).to eq(redirect["nonce"])
      end
    end

    context "with an unregistered deployment" do
      it "returns 404" do
        post lti_login_path, params: { iss: "https://unknown.example.com", client_id: "bad-id" }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /lti/launch with id_token (LTI 1.3)" do
    before do
      stub_request(:get, deployment.jwks_url).to_return(status: 404, body: "")
    end

    context "with a completed OIDC login and matching state/nonce" do
      it "signs the user in and redirects to root" do
        login = complete_oidc_login
        post lti_launch_path, params: { id_token: id_token("nonce" => login[:nonce]), state: login[:state] }
        expect(response).to redirect_to(root_path)
      end

      it "creates the user when they do not exist in CircuitVerse" do
        login = complete_oidc_login
        expect do
          post lti_launch_path,
               params: { id_token: id_token("email" => "newuser@example.com", "nonce" => login[:nonce]),
                         state: login[:state] }
        end.to change(User, :count).by(1)
      end

      it "reuses the same account across launches with the same sub" do
        login = complete_oidc_login
        post lti_launch_path,
             params: { id_token: id_token("sub" => "lti-subject-123", "nonce" => login[:nonce]),
                       state: login[:state] }
        expect do
          relogin = complete_oidc_login
          post lti_launch_path,
               params: { id_token: id_token("sub" => "lti-subject-123", "nonce" => relogin[:nonce]),
                         state: relogin[:state] }
        end.not_to change(User, :count)
      end

      it "sets is_lti in the session" do
        login = complete_oidc_login
        post lti_launch_path, params: { id_token: id_token("nonce" => login[:nonce]), state: login[:state] }
        expect(session[:is_lti]).to be true
      end
    end

    context "when the email claim belongs to a different existing account" do
      it "rejects the launch instead of signing in as that account" do
        FactoryBot.create(:user, email: "existing@example.com")
        login = complete_oidc_login
        expect do
          post lti_launch_path,
               params: { id_token: id_token("email" => "existing@example.com", "nonce" => login[:nonce]),
                         state: login[:state] }
        end.not_to change(User, :count)
        expect(response).to have_http_status(:conflict)
      end
    end

    context "when the token omits the email claim" do
      it "returns 401 rather than 500" do
        login = complete_oidc_login
        now = Time.current.to_i
        token = JWT.encode(
          { "iss" => deployment.issuer, "aud" => deployment.client_id,
            LtiController::DEPLOYMENT_ID_CLAIM => deployment.deployment_id,
            "sub" => "no-email-sub", "nonce" => login[:nonce],
            "iat" => now, "exp" => now + 3600 },
          private_key, "RS256"
        )
        post lti_launch_path, params: { id_token: token, state: login[:state] }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "without a prior OIDC login (no session state)" do
      it "rejects a validly signed token with 401" do
        post lti_launch_path, params: { id_token: id_token }
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not provision a user from an unbound launch" do
        expect do
          post lti_launch_path, params: { id_token: id_token("email" => "attacker@example.com") }
        end.not_to change(User, :count)
      end
    end

    context "with a forged state not signed by the tool" do
      it "returns 401" do
        post lti_launch_path, params: { id_token: id_token, state: "forged-unsigned-state" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a state that has expired" do
      it "returns 401" do
        verifier = Rails.application.message_verifier(LtiController::LTI_STATE_PURPOSE)
        expired_state = verifier.generate(
          { "nonce" => "test-nonce" },
          purpose: LtiController::LTI_STATE_PURPOSE,
          expires_at: 1.minute.ago
        )
        post lti_launch_path, params: { id_token: id_token("nonce" => "test-nonce"), state: expired_state }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a deployment_id that matches no registered deployment" do
      it "returns 404" do
        login = complete_oidc_login
        token = id_token(LtiController::DEPLOYMENT_ID_CLAIM => "unregistered-deployment",
                         "nonce" => login[:nonce])
        post lti_launch_path, params: { id_token: token, state: login[:state] }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an unknown issuer in the token" do
      it "returns 404" do
        login = complete_oidc_login
        token = JWT.encode(
          { "iss" => "https://unknown.edu", "aud" => "unknown-client", "sub" => "u1",
            LtiController::DEPLOYMENT_ID_CLAIM => "deploy-unknown",
            "iat" => Time.current.to_i, "exp" => 1.hour.from_now.to_i },
          private_key, "RS256"
        )
        post lti_launch_path, params: { id_token: token, state: login[:state] }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a malformed token" do
      it "returns 401" do
        login = complete_oidc_login
        post lti_launch_path, params: { id_token: "not.a.jwt", state: login[:state] }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired token" do
      it "returns 401" do
        login = complete_oidc_login
        expired = id_token("exp" => 1.hour.ago.to_i, "nonce" => login[:nonce])
        post lti_launch_path, params: { id_token: expired, state: login[:state] }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a token missing a required claim" do
      it "returns 401 rather than 500" do
        login = complete_oidc_login
        now = Time.current.to_i
        token = JWT.encode(
          { "iss" => deployment.issuer, "aud" => deployment.client_id,
            LtiController::DEPLOYMENT_ID_CLAIM => deployment.deployment_id,
            "nonce" => login[:nonce], "iat" => now, "exp" => now + 3600 },
          private_key, "RS256"
        )
        post lti_launch_path, params: { id_token: token, state: login[:state] }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /lti/launch without id_token (no LTI 1.1 assignment found)" do
    it "returns 401 when no matching assignment exists" do
      post lti_launch_path
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "when the lti_advantage feature flag is disabled" do
    before { Flipper.disable(:lti_advantage) }

    it "returns 404 for the tool configuration" do
      get lti_config_path
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for the JWKS endpoint" do
      get lti_jwks_path
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for OIDC login initiation" do
      post lti_login_path, params: {
        iss: deployment.issuer, client_id: deployment.client_id,
        login_hint: "hint_abc", target_link_uri: "http://www.example.com/lti/launch"
      }
      expect(response).to have_http_status(:not_found)
    end

    it "does not provision a user from a 1.3 launch and returns 404" do
      verifier = Rails.application.message_verifier(LtiController::LTI_STATE_PURPOSE)
      state = verifier.generate({ "nonce" => "test-nonce" },
                                purpose: LtiController::LTI_STATE_PURPOSE, expires_in: 5.minutes)
      expect do
        post lti_launch_path, params: { id_token: id_token("nonce" => "test-nonce"), state: state }
      end.not_to change(User, :count)
      expect(response).to have_http_status(:not_found)
    end

    it "still allows the LTI 1.1 launch path" do
      post lti_launch_path
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
