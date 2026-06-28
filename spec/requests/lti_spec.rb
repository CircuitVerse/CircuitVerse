# frozen_string_literal: true

require "rails_helper"

describe LtiController, type: :request do
  let(:private_key)    { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key_pem) { private_key.public_key.to_pem }
  let!(:deployment)    { FactoryBot.create(:lti_deployment, platform_public_key: public_key_pem) }

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

  # Performs the OIDC login initiation so the session holds a valid
  # lti_state / lti_nonce, mirroring a real LTI 1.3 launch.
  def complete_oidc_login
    post lti_login_path, params: {
      iss: deployment.issuer,
      client_id: deployment.client_id,
      login_hint: "hint_abc",
      target_link_uri: "http://www.example.com/lti/launch"
    }
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

      it "stores lti_nonce and lti_state in the session" do
        post lti_login_path, params: login_params
        expect(session[:lti_nonce]).to be_present
        expect(session[:lti_state]).to be_present
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
        complete_oidc_login
        post lti_launch_path, params: { id_token: id_token("nonce" => session[:lti_nonce]), state: session[:lti_state] }
        expect(response).to redirect_to(root_path)
      end

      it "creates the user when they do not exist in CircuitVerse" do
        complete_oidc_login
        nonce = session[:lti_nonce]
        state = session[:lti_state]
        expect do
          post lti_launch_path,
               params: { id_token: id_token("email" => "newuser@example.com", "nonce" => nonce), state: state }
        end.to change(User, :count).by(1)
      end

      it "reuses an existing CircuitVerse account matched by email" do
        existing = FactoryBot.create(:user, email: "existing@example.com")
        complete_oidc_login
        nonce = session[:lti_nonce]
        state = session[:lti_state]
        expect do
          post lti_launch_path,
               params: { id_token: id_token("email" => existing.email, "nonce" => nonce), state: state }
        end.not_to change(User, :count)
      end

      it "sets is_lti in the session" do
        complete_oidc_login
        post lti_launch_path, params: { id_token: id_token("nonce" => session[:lti_nonce]), state: session[:lti_state] }
        expect(session[:is_lti]).to be true
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

    context "with a state that does not match the session" do
      it "returns 401" do
        complete_oidc_login
        post lti_launch_path, params: { id_token: id_token, state: "wrong-state" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with a deployment_id that matches no registered deployment" do
      it "returns 404" do
        complete_oidc_login
        token = id_token(LtiController::DEPLOYMENT_ID_CLAIM => "unregistered-deployment",
                         "nonce" => session[:lti_nonce])
        post lti_launch_path, params: { id_token: token, state: session[:lti_state] }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an unknown issuer in the token" do
      it "returns 404" do
        complete_oidc_login
        token = JWT.encode(
          { "iss" => "https://unknown.edu", "aud" => "unknown-client", "sub" => "u1",
            LtiController::DEPLOYMENT_ID_CLAIM => "deploy-unknown",
            "iat" => Time.current.to_i, "exp" => 1.hour.from_now.to_i },
          private_key, "RS256"
        )
        post lti_launch_path, params: { id_token: token, state: session[:lti_state] }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a malformed token" do
      it "returns 401" do
        complete_oidc_login
        post lti_launch_path, params: { id_token: "not.a.jwt", state: session[:lti_state] }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired token" do
      it "returns 401" do
        complete_oidc_login
        expired = id_token("exp" => 1.hour.ago.to_i, "nonce" => session[:lti_nonce])
        post lti_launch_path, params: { id_token: expired, state: session[:lti_state] }
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
end
