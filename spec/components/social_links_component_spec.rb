# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialLinksComponent, type: :component do
  include Capybara::RSpecMatchers

  it "renders social links in the footer" do
    rendered_html = render_inline(described_class.new).to_html
    rendered = Capybara.string(rendered_html)

    # Debugging: Output the rendered HTML
    # puts rendered_html

    aggregate_failures do
      expect(rendered).to have_css(".footer-social-icons-container")
      expect(rendered).to have_link(nil, href: "https://www.facebook.com/CircuitVerse")
      expect(rendered).to have_link(nil, href: "https://twitter.com/CircuitVerse")
      expect(rendered).to have_link(nil, href: "https://www.linkedin.com/company/circuitverse")
      expect(rendered).to have_link(nil, href: "https://www.youtube.com/c/CircuitVerse")
      expect(rendered).to have_link(nil, href: "https://github.com/CircuitVerse")
      expect(rendered).to have_css("img.footer-social-icon", count: 5)
    end
  end
end
