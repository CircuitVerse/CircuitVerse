# frozen_string_literal: true

require "rails_helper"

RSpec.describe SocialCardComponent, type: :component do
  it "renders the social card with correct content" do
    render_inline(described_class.new(
                    link_url: "https://github.com/CircuitVerse",
                    image_path: "SVGs/github.svg",
                    image_alt: "Github Logo",
                    heading: "Contribute at GitHub",
                    description: "Help us improve CircuitVerse"
                  ))

    expect(page).to have_css(".social-card.contribute-social-card")
    expect(page).to have_link(href: "https://github.com/CircuitVerse")
    expect(page).to have_css("img.social-card-image[alt='Github Logo']")
    expect(page).to have_css("h6", text: "Contribute at GitHub")
    expect(page).to have_css("p", text: "Help us improve CircuitVerse")
  end
end
