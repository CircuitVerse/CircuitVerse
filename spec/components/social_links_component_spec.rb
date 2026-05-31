# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialLinksComponent, type: :component do
  it "renders social links" do
    render_inline(described_class.new)

    aggregate_failures do
      expect(page).to have_css(".footer-social-icons-row")
      expect(page).to have_link(href: "/facebook")
      expect(page).to have_link(href: "/twitter")
      expect(page).to have_link(href: "/linkedin")
      expect(page).to have_link(href: "/youtube")
      expect(page).to have_link(href: "/github")
      expect(page).to have_css("img.footer-social-icon", count: 5)
    end
  end
end
