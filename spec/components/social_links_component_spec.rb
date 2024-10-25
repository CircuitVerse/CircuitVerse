# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialLinksComponent, type: :component do
  context "when GitLab integration is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:gitlab_integration).and_return(true)
    end

    it "renders social links including GitLab" do
      render_inline(described_class.new)

      aggregate_failures do
        expect(page).to have_css(".social-icons-row")
        expect(page).to have_link(href: user_google_oauth2_omniauth_authorize_path)
        expect(page).to have_link(href: user_facebook_omniauth_authorize_path)
        expect(page).to have_link(href: user_github_omniauth_authorize_path)
        expect(page).to have_link(href: user_gitlab_omniauth_authorize_path)
        expect(page).to have_css("img.users-social-links", count: 4)
      end
    end
  end

  context "when GitLab integration is disabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:gitlab_integration).and_return(false)
    end

    it "renders social links without GitLab" do
      render_inline(described_class.new)

      aggregate_failures do
        expect(page).to have_css(".social-icons-row")
        expect(page).to have_link(href: user_google_oauth2_omniauth_authorize_path)
        expect(page).to have_link(href: user_facebook_omniauth_authorize_path)
        expect(page).to have_link(href: user_github_omniauth_authorize_path)
        expect(page).not_to have_link(href: user_gitlab_omniauth_authorize_path)
        expect(page).to have_css("img.users-social-links", count: 3)
      end
    end
  end
end