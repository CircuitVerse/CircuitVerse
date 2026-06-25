# frozen_string_literal: true

require "rails_helper"

describe LtiController, type: :request do
  let(:private_key)    { OpenSSL::PKey::RSA.generate(2048) }
  let(:public_key_pem) { private_key.public_key.to_pem }
  let!(:deployment)    { FactoryBot.create(:lti_deployment, platform_public_key: public_key_pem) }

  def id_token(overrides = {})
    now = Time.current.to_i
    payload = {
      "iss"   => deployment.issuer,
      "aud"   => deployment.client_id,
      "sub"   => SecureRandom.uuid,
      "nonce" => "test-nonce",
      "iat"   => now,
      "exp"   => now + 3600,
      "email" => "student@example.com",
      "name"  => "Test Student"
    }.merge(overrides)
    JWT.encode(payload, private_key, "RS256")
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
      body = JSON.parse(response.body)
      expect(body["keys"]).to be_an(Array)
      expect(body["keys"].first["kty"]).to eq("RSA")
    end
  end

  describe "GET /lti/config" do
    it "returns the tool configuration JSON" do
      get lti_config_path
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["title"]).to eq("CircuitVerse")
      expect(body).to have_key("oidc_initiation_url")
      expect(body).to have_key("target_link_uri")
    end
  end

  describe "POST /lti/login (OIDC initiation)" do
    let(:login_params) do
      {
        iss:             deployment.issuer,
        client_id:       deployment.client_id,
        login_hint:      "hint_abc",
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
    context "with a valid token and no prior OIDC state" do
      it "signs the user in and redirects to root" do
        post lti_launch_path, params: { id_token: id_token }
        expect(response).to redirect_to(root_path)
      end

      it "creates the user when they do not exist in CircuitVerse" do
        expect {
          post lti_launch_path, params: { id_token: id_token("email" => "newuser@example.com") }
        }.to change(User, :count).by(1)
      end

      it "reuses an existing CircuitVerse account matched by email" do
        existing = FactoryBot.create(:user, email: "existing@example.com")
        expect {
          post lti_launch_path, params: { id_token: id_token("email" => existing.email) }
        }.not_to change(User, :count)
      end

      it "sets is_lti in the session" do
        post lti_launch_path, params: { id_token: id_token }
        expect(session[:is_lti]).to be true
      end
    end

    context "with state mismatch after OIDC login" do
      it "returns 401" do
        post lti_login_path, params: {
          iss:             deployment.issuer,
          client_id:       deployment.client_id,
          login_hint:      "hint",
          target_link_uri: "http://www.example.com/lti/launch"
        }
        post lti_launch_path, params: { id_token: id_token, state: "wrong-state" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an unknown issuer in the token" do
      it "returns 404" do
        token = JWT.encode(
          { "iss" => "https://unknown.edu", "aud" => "unknown-client",
            "sub" => "u1", "iat" => Time.current.to_i, "exp" => 1.hour.from_now.to_i },
          private_key, "RS256"
        )
        post lti_launch_path, params: { id_token: token }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a malformed token" do
      it "returns 401" do
        post lti_launch_path, params: { id_token: "not.a.jwt" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired token" do
      it "returns 401" do
        expired = id_token("exp" => 1.hour.ago.to_i)
        post lti_launch_path, params: { id_token: expired }
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
