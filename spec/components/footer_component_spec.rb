# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { instance_double(User, id: 1) }

  before do
    allow(Flipper).to receive(:enabled?).and_return(false)
  end

  it "renders footer with all components" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_css(".footer-container")
    expect(page).to have_css(".footer-logo")
    expect(page).to have_css(".footer-social-icon-text")
    expect(page).to have_css(".footer-sponsor-logo")
    expect(page).to have_css(".footer-copyright-text")
  end

  it "renders footer with modern structure" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_css(".footer-main-row")
    expect(page).to have_css(".footer-brand-section")
    expect(page).to have_css(".footer-links-section")
    expect(page).to have_css(".footer-sponsors-section")
    expect(page).to have_css(".footer-copyright-row")
  end

  it "renders current year in copyright text" do
    render_inline(described_class.new(current_user: nil))

    expect(page).to have_text(Time.current.year.to_s)
  end

  it "renders SocialLinksComponent with hover effects" do
    social_links_component = instance_double(SocialLinksComponent)
    allow(SocialLinksComponent).to receive(:new).and_return(social_links_component)
    allow(social_links_component).to receive(:render_in)

    render_inline(described_class.new(current_user: nil))
  end

  it "renders FooterLinksComponent with current_user" do
    footer_links_component = instance_double(FooterLinksComponent)
    allow(FooterLinksComponent).to receive(:new).with(user).and_return(footer_links_component)
    allow(footer_links_component).to receive(:render_in)

    render_inline(described_class.new(current_user: user))
  end

  it "includes proper CSS classes for hover effects" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_css(".footer-logo-link")
    expect(page).to have_css(".footer-social-link")
    expect(page).to have_css(".footer-link-item")
    expect(page).to have_css(".footer-sponsor-link")
    expect(page).to have_css(".footer-social-icons-container")
  end

  it "has responsive design classes" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_css(".footer-links-grid")
    expect(page).to have_css(".footer-sponsors-grid")
    expect(page).to have_css(".footer-sponsors-item")
  end

  it "has proper spacing between sections" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_css(".footer-main-row")
    expect(page).to have_css(".footer-copyright-row")
  end
end
