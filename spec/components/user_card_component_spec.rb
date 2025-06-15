# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchComponents::UserCardComponent, type: :component do
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }
  let(:profile) { ProfileDecorator.new(user) }

  it "renders user card with profile information" do
    render_inline(described_class.new(profile: profile))

    aggregate_failures do
      expect(page).to have_css(".search-user-container")
      expect(page).to have_css(".search-username", text: profile.name)
      expect(page).to have_css(".search-user-details-text", count: 4)
      expect(page).to have_link(href: user_path(profile))
      expect(page).to have_css(".search-horizontal-rule")
    end
  end

  it "displays user profile image" do
    render_inline(described_class.new(profile: profile))

    expect(page).to have_css("img.search-usersearch-image")
  end

  it "displays user details with correct content" do
    render_inline(described_class.new(profile: profile))

    aggregate_failures do
      expect(page).to have_text("Member since:")
      expect(page).to have_text("Educational Institution:")
      expect(page).to have_text("Country:")
      expect(page).to have_text("Total Circuits Made:")
      expect(page).to have_text(profile.member_since)
      expect(page).to have_text(profile.educational_institute)
      expect(page).to have_text(profile.country_name)
      expect(page).to have_text(profile.total_circuits)
    end
  end

  it "displays view profile link" do
    render_inline(described_class.new(profile: profile))

    expect(page).to have_link(I18n.t("view"), href: user_path(profile))
  end
end
