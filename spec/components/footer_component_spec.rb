# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { double("User", id: 1) }

  it "renders the footer with all components" do
    render_inline(FooterComponent.new(current_user: user))

    expect(page).to have_css(".footer-container")
    expect(page).to have_css(".footer-logo")
    expect(page).to have_css(".footer-social-icon-text")
    expect(page).to have_css(".footer-sponsor-logo")
    expect(page).to have_css(".footer-copyright-text")
  end

  it "renders the current year in the copyright text" do
    render_inline(FooterComponent.new(current_user: nil))

    expect(page).to have_text(Time.current.year.to_s)
  end

  it "renders SocialLinksComponent" do
    allow(SocialLinksComponent).to receive(:new).and_return(double(render_in: nil))
    render_inline(FooterComponent.new(current_user: nil))

    expect(SocialLinksComponent).to have_received(:new)
  end

  it "renders FooterLinksComponent with current_user" do
    allow(FooterLinksComponent).to receive(:new).and_return(double(render_in: nil))
    render_inline(FooterComponent.new(current_user: user))

    expect(FooterLinksComponent).to have_received(:new).with(user)
  end
end
