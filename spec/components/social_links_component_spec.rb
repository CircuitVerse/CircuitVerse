# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialLinksComponent, type: :component do
  it "renders social links in the footer" do
    render_inline(described_class.new)

    aggregate_failures do
      expect(rendered_component).to have_css(".footer-social-icons-container")
      expect(rendered_component).to have_link(href: "https://www.facebook.com/CircuitVerse")
      expect(rendered_component).to have_link(href: "https://twitter.com/CircuitVerse")
      expect(rendered_component).to have_link(href: "https://www.linkedin.com/company/circuitverse")
      expect(rendered_component).to have_link(href: "https://www.youtube.com/c/CircuitVerse")
      expect(rendered_component).to have_link(href: "https://github.com/CircuitVerse")
      expect(rendered_component).to have_css("img.footer-social-icon", count: 5)
    end
  end
end
