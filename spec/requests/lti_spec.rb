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

  describe "LTI 1.3 deep linking picker" do
    let(:instructor) { FactoryBot.create(:user) }
    let(:settings) { "signed-deep-linking-settings" }

    before { Flipper.enable(:lti_advantage) }

    after { Flipper.disable(:lti_advantage) }

    it "returns not found when the flag is disabled" do
      Flipper.disable(:lti_advantage)
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response).to have_http_status(:not_found)
    end

    it "sends an anonymous instructor to sign in" do
      get "/lti/deep_link", params: { settings: settings }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "lists the instructor's own circuits" do
      project = FactoryBot.create(:project, author: instructor, name: "Half Adder")
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).to include("Half Adder", "project:#{project.id}")
    end

    it "lists assignments the instructor mentors" do
      group = FactoryBot.create(:group, primary_mentor: instructor)
      assignment = FactoryBot.create(:assignment, group: group, name: "Week 1 Lab")
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).to include("Week 1 Lab", "assignment:#{assignment.id}")
    end

    it "offers the most recently updated assignments first" do
      group = FactoryBot.create(:group, primary_mentor: instructor)
      FactoryBot.create(:assignment, group: group, name: "Older", deadline: 1.day.from_now,
                                     updated_at: 2.days.ago)
      FactoryBot.create(:assignment, group: group, name: "Newer", deadline: 9.days.from_now,
                                     updated_at: 1.minute.ago)
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body.index("Newer")).to be < response.body.index("Older")
    end

    it "offers featured circuits as templates" do
      featured = FactoryBot.create(:featured_circuit)
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).to include(featured.project.name, "project:#{featured.project.id}")
    end

    it "does not offer an unfeatured public circuit as a template" do
      FactoryBot.create(:project, :public, author: FactoryBot.create(:user), name: "Not Featured")
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).not_to include("Not Featured")
    end

    it "does not repeat the instructor's own featured circuit under templates" do
      own = FactoryBot.create(:project, :public, author: instructor, name: "My Featured")
      FactoryBot.create(:featured_circuit, project: own)
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body.scan(%(value="project:#{own.id}")).size).to eq(1)
    end

    it "does not offer another author's circuits" do
      FactoryBot.create(:project, author: FactoryBot.create(:user), name: "Someone Elses")
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).not_to include("Someone Elses")
    end

    it "does not offer assignments from groups the instructor does not mentor" do
      other_group = FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user))
      FactoryBot.create(:assignment, group: other_group, name: "Not Mine")
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).not_to include("Not Mine")
    end

    it "carries the settings through to the submission" do
      sign_in instructor
      get "/lti/deep_link", params: { settings: settings }

      expect(response.body).to include(settings)
    end
  end
end
