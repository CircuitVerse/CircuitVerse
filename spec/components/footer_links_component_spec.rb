# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterLinksComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:user) { instance_double(User, id: 1) }

  before do
    allow(Flipper).to receive(:enabled?).and_return(false)
  end

  it "renders common footer links for guest users" do
    render_inline(described_class.new(nil))

    expect(page).to have_link(I18n.t("layout.link_to_simulator"), href: "/simulator")
    expect(page).to have_link(I18n.t("layout.link_to_learn_more"), href: "/learn")
    expect(page).to have_link(I18n.t("login"), href: "/users/sign_in")
    expect(page).not_to have_link(I18n.t("layout.footer.my_circuits"))
  end

  it "renders common footer links for signed-in users" do
    render_inline(described_class.new(user))

    expect(page).to have_link(I18n.t("layout.link_to_simulator"), href: "/simulator")
    expect(page).to have_link(I18n.t("layout.footer.my_circuits"), href: "/users/1")
    expect(page).not_to have_link(I18n.t("login"))
  end

  it "renders forum link when enabled" do
    allow(Flipper).to receive(:enabled?).with(:forum).and_return(true)
    render_inline(described_class.new(nil))

    expect(page).to have_link(I18n.t("layout.footer.link_to_forum"), href: "https://circuitverse.discourse.group")
  end

  it "does not render forum link when disabled" do
    allow(Flipper).to receive(:enabled?).with(:forum).and_return(false)
    render_inline(described_class.new(nil))

    expect(page).not_to have_link(I18n.t("layout.footer.link_to_forum"))
  end

  # The cursor fix in footer.scss is scoped with a direct-child selector:
  #   .footer-links > a { display: block; width: fit-content; }
  # It must apply to the affected links (whose <h6> is wrapped BY the anchor,
  # making the anchor a direct child of .footer-links) and must NOT touch the
  # Forum link (whose anchor is nested INSIDE an <h6>, so it is not a direct
  # child and was never affected). These tests lock in that structure.

  it "renders affected links as direct-child anchors wrapping an <h6> (targeted by the > a fix)" do
    render_inline(described_class.new(nil))

    direct_anchors = page.all(".footer-links > a", visible: :all)
    expect(direct_anchors).not_to be_empty

    # Every anchor the CSS `> a` rule matches wraps a block-level <h6>.
    expect(direct_anchors).to all(have_css("h6", visible: :all))

    # The links the maintainer listed as affected are all in that set.
    hrefs = direct_anchors.pluck(:href)
    expect(hrefs).to include(
      "/simulator",
      "/docs",
      "https://docs.circuitverse.org/chapter8/chapter8-cvfaq",
      "/users/sign_in"
    )
  end

  it "keeps the Forum anchor nested inside its <h6> so the > a fix skips it" do
    allow(Flipper).to receive(:enabled?).with(:forum).and_return(true)
    render_inline(described_class.new(nil))

    forum_href = "https://circuitverse.discourse.group"

    # The Forum anchor renders inside an <h6> (not as a direct child)...
    expect(page).to have_css(".footer-links > h6 > a[href='#{forum_href}']", visible: :all)
    # ...so the direct-child `> a` selector intentionally leaves it untouched.
    expect(page).not_to have_css(".footer-links > a[href='#{forum_href}']", visible: :all)
  end
end
