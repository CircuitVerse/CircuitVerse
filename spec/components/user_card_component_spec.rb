# frozen_string_literal: true

require "rails_helper"

RSpec.describe User::UserCardComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }
  let(:profile) { ProfileDecorator.new(user) }

  it "renders user card with profile information" do
    render_inline(described_class.new(profile: profile))

    aggregate_failures do
      expect(page).to have_css(".search-user-card")
      expect(page).to have_css(".search-user-card-name", text: profile.name)
      expect(page).to have_css(".search-user-card-detail", count: 3)
      expect(page).to have_link(href: user_path(profile))
    end
  end

  it "displays user profile image" do
    render_inline(described_class.new(profile: profile))

    expect(page).to have_css("img.search-user-card-avatar")
  end

  it "displays user details with correct content" do
    render_inline(described_class.new(profile: profile))

    aggregate_failures do
      expect(page).to have_content("#{I18n.t('users.circuitverse.member_for')} #{profile.member_since}")
      expect(page).to have_content(profile.educational_institute)
      expect(page).to have_content(profile.country_name)
      expect(page).to have_content("#{profile.total_circuits} #{I18n.t('users.circuitverse.total_circuits')}")
    end
  end
end
