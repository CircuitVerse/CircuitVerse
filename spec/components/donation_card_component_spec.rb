require "rails_helper"

RSpec.describe DonationCardComponent, type: :component do
  it "renders donation card correctly" do
    render_inline(described_class.new(
      image_path: "logos/opencollective-logo.png",
      link: "https://opencollective.com/CircuitVerse/contribute",
      alt_text: "Open Collective Logo",
      description: "Donate via Open Collective"
    ))

    expect(page).to have_css("img[alt='Open Collective Logo']")
    expect(page).to have_link(href: "https://opencollective.com/CircuitVerse/contribute")
    expect(page).to have_text("Donate via Open Collective")
  end
end

