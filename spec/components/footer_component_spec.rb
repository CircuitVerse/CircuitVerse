# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { instance_double(User, id: 1) }

  it "renders the footer with all components" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_css(".footer-container")
    expect(page).to have_css(".footer-logo")
    expect(page).to have_css(".footer-social-icon-text")
    expect(page).to have_css(".footer-sponsor-logo")
    expect(page).to have_css(".footer-copyright-text")
  end

  it "renders the current year in the copyright text" do
    render_inline(described_class.new(current_user: nil))

    expect(page).to have_text(Time.current.year.to_s)
  end

  it "renders SocialLinksComponent" do
    social_links_component = instance_double(SocialLinksComponent)
    allow(SocialLinksComponent).to receive(:new).and_return(social_links_component)
    allow(social_links_component).to receive(:render_in)

    render_inline(described_class.new(current_user: nil))
    # Confirm that the SocialLinksComponent content is included in the rendered output
    expect(rendered).to include("SocialLinksComponent") # Update based on actual rendered output
  end

  it "renders FooterLinksComponent with current_user" do
    footer_links_component = instance_double(FooterLinksComponent)
    allow(FooterLinksComponent).to receive(:new).with(user).and_return(footer_links_component)
    allow(footer_links_component).to receive(:render_in)

    render_inline(described_class.new(current_user: user))
    # Confirm that the FooterLinksComponent renders correctly
    expect(rendered).to have_selector(".footer-links-component") # Update based on actual rendered output
  end
end
