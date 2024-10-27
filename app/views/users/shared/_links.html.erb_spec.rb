# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/shared/_links.html.erb", type: :view do
  include Devise::Test::ControllerHelpers
  include Rails.application.routes.url_helpers

  before do
    # Set up default URL options if needed
    default_url_options[:host] = "test.host"

    # Stub the necessary route helpers
    allow(view).to receive(:user_google_oauth2_omniauth_authorize_path).and_return("/users/auth/google_oauth2")
    allow(view).to receive(:user_facebook_omniauth_authorize_path).and_return("/users/auth/facebook")
    allow(view).to receive(:user_github_omniauth_authorize_path).and_return("/users/auth/github")
    allow(view).to receive(:user_gitlab_omniauth_authorize_path).and_return("/users/auth/gitlab")
    allow(view).to receive(:new_confirmation_path).and_return("/users/confirmation/new")

    # Stub Flipper feature flags
    allow(Flipper).to receive(:enabled?).with(:gitlab_integration).and_return(true)
    allow(Flipper).to receive(:enabled?).with(:sso_integration).and_return(false)

    # Assign Devise mappings
    assign(:resource, User.new)
    assign(:resource_name, :user)
    allow(view).to receive(:devise_mapping).and_return(Devise.mappings[:user])

    # Stub controller_name if used
    allow(view).to receive(:controller_name).and_return("sessions")

    # Stub translations if necessary
    allow(view).to receive(:t).and_call_original
    allow(view).to receive(:t).with("users.shared.login_with").and_return("Login with")
    allow(view).to receive(:t).with("groups.use_alternative").and_return("Use alternative")
    allow(view).to receive(:t).with("users.shared.login_with_sso").and_return("Login with SSO")
    allow(view).to receive(:t).with("users.shared.resend_email").and_return("Didn't receive confirmation instructions?")
  end

  context "when GitLab integration is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:gitlab_integration).and_return(true)
    end

    it "renders social login links including GitLab" do
      render partial: "users/shared/links"

      aggregate_failures do
        expect(rendered).to have_css(".social-icons-row")
        expect(rendered).to have_link(href: "/users/auth/google_oauth2", method: :post)
        expect(rendered).to have_link(href: "/users/auth/facebook", method: :post)
        expect(rendered).to have_link(href: "/users/auth/github", method: :post)
        expect(rendered).to have_link(href: "/users/auth/gitlab", method: :post)
        expect(rendered).to have_css("img.users-social-links", count: 4)
      end
    end
  end

  context "when GitLab integration is disabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:gitlab_integration).and_return(false)
    end

    it "renders social login links without GitLab" do
      render partial: "users/shared/links"

      aggregate_failures do
        expect(rendered).to have_css(".social-icons-row")
        expect(rendered).to have_link(href: "/users/auth/google_oauth2", method: :post)
        expect(rendered).to have_link(href: "/users/auth/facebook", method: :post)
        expect(rendered).to have_link(href: "/users/auth/github", method: :post)
        expect(rendered).not_to have_link(href: "/users/auth/gitlab", method: :post)
        expect(rendered).to have_css("img.users-social-links", count: 3)
      end
    end
  end

  context "when SSO integration is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:sso_integration).and_return(true)
    end

    it "renders SSO login link" do
      render partial: "users/shared/links"

      expect(rendered).to have_link("Login with SSO", href: "/users/saml/sign_in")
    end
  end

  context "when SSO integration is disabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:sso_integration).and_return(false)
    end

    it "does not render SSO login link" do
      render partial: "users/shared/links"

      expect(rendered).not_to have_link("Login with SSO", href: "/users/saml/sign_in")
    end
  end

  context "when confirmable is enabled" do
    before do
      # Assuming confirmable is enabled in Devise mappings
      mapping = Devise.mappings[:user]
      allow(mapping).to receive(:confirmable?).and_return(true)
      allow(view).to receive(:controller_name).and_return("sessions")
      allow(view).to receive(:devise_mapping).and_return(mapping)
    end

    it "renders resend confirmation email link" do
      render partial: "users/shared/links"

      expect(rendered).to have_link("Didn't receive confirmation instructions?", href: "/users/confirmation/new")
    end
  end

  context "when confirmable is disabled" do
    before do
      mapping = Devise.mappings[:user]
      allow(mapping).to receive(:confirmable?).and_return(false)
      allow(view).to receive(:devise_mapping).and_return(mapping)
    end

    it "does not render resend confirmation email link" do
      render partial: "users/shared/links"

      expect(rendered).not_to have_link("Didn't receive confirmation instructions?", href: "/users/confirmation/new")
    end
  end
end
