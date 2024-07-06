# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterLinksComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { double("User", id: 1) }

  it "renders common footer links for guest users" do
    render_inline(FooterLinksComponent.new(nil))

    expect(page).to have_link(I18n.t("layout.link_to_simulator"), href: "/simulator")
    expect(page).to have_link(I18n.t("layout.link_to_learn_more"), href: "/learn")
    expect(page).to have_link(I18n.t("layout.link_to_blog"), href: "https://blog.circuitverse.org")
    expect(page).to have_link(I18n.t("layout.footer.link_to_examples"), href: "/examples")
    expect(page).to have_link(I18n.t("layout.link_to_docs"), href: "/docs")
    expect(page).to have_link(I18n.t("layout.footer.link_to_contribute"), href: "/contribute")
    expect(page).to have_link(I18n.t("layout.link_to_teachers"), href: "/teachers")
    expect(page).to have_link(I18n.t("layout.link_to_about"), href: "/about")
    expect(page).to have_link(I18n.t("layout.link_to_faq"), href: "https://docs.circuitverse.org/#/chapter8/2cvfaq")
    expect(page).to have_link(I18n.t("login"), href: "/users/sign_in")
    expect(page).not_to have_link(I18n.t("layout.footer.my_circuits"))
  end

  it "renders common footer links for signed-in users" do
    render_inline(FooterLinksComponent.new(user))

    expect(page).to have_link(I18n.t("layout.link_to_simulator"), href: "/simulator")
    expect(page).to have_link(I18n.t("layout.footer.my_circuits"), href: "/users/1")
    expect(page).not_to have_link(I18n.t("login"))
  end

  it "renders forum link when enabled" do
    allow(Flipper).to receive(:enabled?).with(:forum).and_return(true)
    render_inline(FooterLinksComponent.new(nil))

    expect(page).to have_link(I18n.t("layout.footer.link_to_forum"), href: "/forum")
  end

  it "does not render forum link when disabled" do
    allow(Flipper).to receive(:enabled?).with(:forum).and_return(false)
    render_inline(FooterLinksComponent.new(nil))

    expect(page).not_to have_link(I18n.t("layout.footer.link_to_forum"))
  end
end
