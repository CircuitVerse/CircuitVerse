# frozen_string_literal: true

require "rails_helper"

describe LtiController, type: :request do
  before do
    Flipper.enable(:lms_integration)
    @oauth_consumer_key_fromlms = "some_keys"
    @oauth_shared_secret_fromlms = "some_secrets"
    @lti_launch_path = "/lti/launch"
    get "/"
    @host = request.host
    @port = request.port
  end

  after do
    Flipper.disable(:lms_integration)
  end

  describe "CircuitVerse as LTI Provider" do
    before do
      # creation of assignment and required users
      @primary_mentor = FactoryBot.create(:user)
      @group = FactoryBot.create(:group, primary_mentor: primary_mentor)
      @member = FactoryBot.create(:user)
      @not_member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, user: member, group: group)
      @assignment = FactoryBot.create(:assignment,
                                      group: group,
                                      grading_scale: 2,
                                      lti_consumer_key: oauth_consumer_key_fromlms,
                                      lti_shared_secret: oauth_shared_secret_fromlms)
    end

    context "when lti parameters are valid" do
      it "returns unauthorized (401) if student is not in the group" do
        lti_request(oauth_consumer_key_fromlms, oauth_shared_secret_fromlms, not_member.email)
        expect(response.code).to eq("401")
      end

      it "returns success (200) if student is in the group" do
        lti_request(oauth_consumer_key_fromlms, oauth_shared_secret_fromlms, member.email)
        expect(response.code).to eq("200")
      end

      it "redirect (302) to assignment page if user is primary mentor" do
        lti_request(oauth_consumer_key_fromlms, oauth_shared_secret_fromlms, primary_mentor.email)
        expect(response.code).to eq("302")
      end
    end

    context "when lti parameters are invalid" do
      it "returns unauthorized (401) if no parameters present" do
        # post to launch url without any parameters
        post lti_launch_path
        expect(response.code).to eq("401")
      end

      it "returns unauthorized (401) if parameters contains invalid assignment credentials" do
        lti_request("some_random", "some_random_secret", member.email)
        expect(response.code).to eq("401")
      end
    end

    context "when storing the grading context in the session" do
      let(:outcome_url) { "https://lms.example.test/outcomes" }

      it "records the outcome context and the matched assignment after a verified launch" do
        lti_request(oauth_consumer_key_fromlms, oauth_shared_secret_fromlms, member.email,
                    "lis_outcome_service_url" => outcome_url)
        expect(session[:lis_outcome_service_url]).to eq(outcome_url)
        expect(session[:lti_11_assignment_id]).to eq(assignment.id)
      end

      it "does not store an outcome context when the launch signature is invalid" do
        post lti_launch_path, params: { oauth_consumer_key: oauth_consumer_key_fromlms,
                                        oauth_signature: "invalid",
                                        lis_outcome_service_url: outcome_url }
        expect(response.code).to eq("401")
        expect(session[:lis_outcome_service_url]).to be_nil
        expect(session[:lti_11_assignment_id]).to be_nil
      end

      it "does not store an outcome context when no assignment matches the consumer key" do
        post lti_launch_path, params: { oauth_consumer_key: "unknown-key",
                                        oauth_signature: "invalid",
                                        lis_outcome_service_url: outcome_url }
        expect(session[:lis_outcome_service_url]).to be_nil
        expect(session[:lti_11_assignment_id]).to be_nil
      end

      it "clears a stale outcome context on the next launch" do
        lti_request(oauth_consumer_key_fromlms, oauth_shared_secret_fromlms, member.email,
                    "lis_outcome_service_url" => outcome_url)
        expect(session[:lti_11_assignment_id]).to eq(assignment.id)

        post lti_launch_path, params: { oauth_consumer_key: "unknown-key",
                                        oauth_signature: "invalid" }
        expect(session[:lis_outcome_service_url]).to be_nil
        expect(session[:lti_11_assignment_id]).to be_nil
      end
    end

    def launch_uri
      # required for generation of LTI parameters
      launch_url = "http://#{host}:#{port}/lti/launch"
      URI(launch_url)
    end

    def parameters(member_email, extra_params = {})
      {
        "launch_url" => launch_uri.to_s,
        "user_id" => SecureRandom.hex(4),
        "launch_presentation_return_url" => launch_uri.to_s,
        "lti_version" => "LTI-1p0",
        "lti_message_type" => "basic-lti-launch-request",
        "resource_link_id" => "88391-e1919-bb3456",
        "lis_person_contact_email_primary" => member_email,
        "tool_consumer_info_product_family_code" => "moodle",
        "context_title" => "sample Course",
        "lis_result_sourcedid" => SecureRandom.hex(10)
      }.merge(extra_params)
    end

    def consumer_data(oauth_consumer_key_fromlms, oauth_shared_secret_fromlms, parameters)
      consumer = IMS::LTI::ToolConsumer.new(
        oauth_consumer_key_fromlms,
        oauth_shared_secret_fromlms,
        parameters
      )
      allow(consumer).to receive(:to_params).and_return(parameters)
      consumer.generate_launch_data
    end

    def lti_request(consumer_key, shared_secret, email, extra_params = {})
      data = consumer_data(consumer_key, shared_secret, parameters(email, extra_params))
      post lti_launch_path, params: data, headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      }
    end

    private

      attr_reader :oauth_consumer_key_fromlms, :oauth_shared_secret_fromlms,
                  :lti_launch_path, :host, :port, :member, :not_member, :primary_mentor,
                  :group, :assignment, :group
  end

  describe "LTI 1.3 OIDC login initiation" do
    include ActiveSupport::Testing::TimeHelpers

    let(:deployment) { FactoryBot.create(:lti_deployment) }
    let(:login_params) do
      {
        iss: deployment.issuer,
        client_id: deployment.client_id,
        login_hint: "lms-user-42",
        lti_message_hint: "message-hint-abc",
        target_link_uri: "http://www.example.com/lti/launch"
      }
    end

    context "when the lti_advantage flag is disabled" do
      it "returns not found" do
        get "/lti/login", params: login_params
  describe "LTI 1.3 tool registration endpoints" do
    context "when the lti_advantage flag is disabled" do
      it "returns not found for the jwks endpoint" do
        get "/lti/jwks"
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for the tool config endpoint" do
        get "/lti/tool_config"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the lti_advantage flag is enabled" do
      before { Flipper.enable(:lti_advantage) }

      after { Flipper.disable(:lti_advantage) }

      it "redirects to the platform's authorization endpoint with the OIDC parameters" do
        get "/lti/login", params: login_params

        expect(response).to have_http_status(:found)
        redirect = URI(response.location)
        expect(redirect.to_s).to start_with(deployment.auth_login_url)
        expect(redirect_params(redirect)).to include(
          "scope" => "openid",
          "response_type" => "id_token",
          "response_mode" => "form_post",
          "prompt" => "none",
          "client_id" => deployment.client_id,
          "redirect_uri" => "#{request.base_url}/lti/launch",
          "login_hint" => "lms-user-42",
          "lti_message_hint" => "message-hint-abc"
        )
      end

      it "signs a state carrying the nonce and the resolved deployment" do
        get "/lti/login", params: login_params

        query = redirect_params(URI(response.location))
        expect(verified_state(query["state"]))
          .to eq("nonce" => query["nonce"], "deployment_id" => deployment.id)
      end

      it "issues a fresh nonce and state for every initiation" do
        get "/lti/login", params: login_params
        first = redirect_params(URI(response.location))
        get "/lti/login", params: login_params
        second = redirect_params(URI(response.location))

        expect(second["nonce"]).not_to eq(first["nonce"])
        expect(second["state"]).not_to eq(first["state"])
      end

      it "expires the state after five minutes" do
        get "/lti/login", params: login_params
        state = redirect_params(URI(response.location))["state"]

        travel_to 6.minutes.from_now do
          expect(verified_state(state)).to be_nil
        end
      end

      it "accepts the cross-site POST the platform sends without a CSRF token" do
        with_forgery_protection { post "/lti/login", params: login_params }
        expect(response).to have_http_status(:found)
      end

      it "resolves the deployment without a client_id when the platform omits it" do
        get "/lti/login", params: login_params.except(:client_id)

        expect(response).to have_http_status(:found)
        expect(verified_state(redirect_params(URI(response.location))["state"]))
          .to include("deployment_id" => deployment.id)
      end

      it "picks the registration matching the client_id when a platform has several" do
        other = FactoryBot.create(:lti_deployment, issuer: deployment.issuer)

        get "/lti/login", params: login_params.merge(client_id: other.client_id)

        expect(verified_state(redirect_params(URI(response.location))["state"]))
          .to include("deployment_id" => other.id)
      end

      it "refuses an ambiguous match rather than guessing a registration" do
        FactoryBot.create(:lti_deployment, issuer: deployment.issuer)

        get "/lti/login", params: login_params.except(:client_id)

        expect(response).to have_http_status(:not_found)
      end

      it "refuses when only lti_deployment_id could disambiguate and it is absent" do
        FactoryBot.create(:lti_deployment,
                          issuer: deployment.issuer, client_id: deployment.client_id)

        get "/lti/login", params: login_params

        expect(response).to have_http_status(:not_found)
      end

      it "keeps query parameters already registered on the authorization endpoint" do
        deployment.update!(auth_login_url: "https://lms.example.com/auth?tenant=acme")

        get "/lti/login", params: login_params

        expect(redirect_params(URI(response.location)))
          .to include("tenant" => "acme", "scope" => "openid")
      end

      it "omits lti_message_hint when the platform does not send one" do
        get "/lti/login", params: login_params.except(:lti_message_hint)

        expect(redirect_params(URI(response.location))).not_to have_key("lti_message_hint")
      end

      it "refuses a registration whose authorization endpoint is not http(s)" do
        deployment.update!(auth_login_url: "javascript:alert(1)")

        get "/lti/login", params: login_params

        expect(response).to have_http_status(:not_found)
      end

      it "narrows to the registration matching lti_deployment_id" do
        other = FactoryBot.create(:lti_deployment,
                                  issuer: deployment.issuer, client_id: deployment.client_id)

        get "/lti/login", params: login_params.merge(lti_deployment_id: other.deployment_id)

        expect(verified_state(redirect_params(URI(response.location))["state"]))
          .to include("deployment_id" => other.id)
      end

      it "returns not found for an unregistered issuer" do
        get "/lti/login", params: login_params.merge(iss: "https://attacker.example.com")
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found when the client_id does not belong to the issuer" do
        get "/lti/login", params: login_params.merge(client_id: "not-our-client")
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found when iss is missing" do
        get "/lti/login", params: login_params.except(:iss)
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found when login_hint is missing" do
        get "/lti/login", params: login_params.except(:login_hint)
        expect(response).to have_http_status(:not_found)
      end
    end

    def redirect_params(uri)
      URI.decode_www_form(uri.query).to_h
    end

    def verified_state(state)
      Rails.application
           .message_verifier(LtiController::LTI_STATE_PURPOSE)
           .verified(state.to_s, purpose: LtiController::LTI_STATE_PURPOSE)
    end

    # The test environment disables forgery protection; turn it on so the
    # token-less POST is actually exercised.
    def with_forgery_protection
      original = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      yield
    ensure
      ActionController::Base.allow_forgery_protection = original
      it "serves the tool's public key set" do
        get "/lti/jwks"
        expect(response).to have_http_status(:ok)
        key = response.parsed_body["keys"].sole
        expect(key).to include("kty" => "RSA", "use" => "sig", "alg" => "RS256")
        expect(key["kid"]).to be_present
        expect(key).not_to have_key("d")
      end

      it "serves the tool configuration for platform registration" do
        get "/lti/tool_config"
        expect(response).to have_http_status(:ok)
        config = response.parsed_body
        expect(config["oidc_initiation_url"]).to eq("#{request.base_url}/lti/login")
        expect(config["target_link_uri"]).to eq("#{request.base_url}/lti/launch")
        expect(config["public_jwk_url"]).to eq("#{request.base_url}/lti/jwks")
        expect(config["scopes"]).to include("https://purl.imsglobal.org/spec/lti-ags/scope/score")
      end
    end
  end
end
