# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController, type: :request do
  let(:callback_path) { "/users/auth/github/callback" }

  def mock_github_auth(email:)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      info: { email: email, name: "OAuth User", nickname: "oauthuser" }
    )
  end

  before do
    OmniAuth.config.test_mode = true
    allow(Flipper).to receive(:enabled?).and_call_original
  end

  after do
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.test_mode = false
  end

  context "when registration is blocked" do
    before do
      allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(true)
    end

    context "with an email that is not registered" do
      before { mock_github_auth(email: "newuser@example.com") }

      it "does not create a user" do
        expect { get callback_path }.not_to change(User, :count)
      end

      it "redirects to the login page with an alert and does not sign in" do
        get callback_path
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq(I18n.t("registration_blocked"))
        expect(controller.current_user).to be_nil
      end
    end

    context "with an email that is already registered" do
      let!(:user) { FactoryBot.create(:user, email: "existing@example.com") }

      before { mock_github_auth(email: "existing@example.com") }

      it "signs the existing user in without creating a new one" do
        expect { get callback_path }.not_to change(User, :count)
        expect(controller.current_user).to eq(user)
      end
    end

    context "with a registered email in different case" do
      before do
        FactoryBot.create(:user, email: "existing@example.com")
        mock_github_auth(email: "Existing@Example.com")
      end

      it "is not blocked" do
        get callback_path
        expect(flash[:alert]).not_to eq(I18n.t("registration_blocked"))
      end
    end

    context "when the provider returns no email" do
      before { mock_github_auth(email: nil) }

      it "does not create a user and redirects to the login page" do
        expect { get callback_path }.not_to change(User, :count)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context "when registration is not blocked" do
    before do
      allow(Flipper).to receive(:enabled?).with(:block_registration).and_return(false)
      mock_github_auth(email: "newuser@example.com")
    end

    it "creates and signs in a new user" do
      expect { get callback_path }.to change(User, :count).by(1)
      expect(controller.current_user.email).to eq("newuser@example.com")
    end
  end
end
