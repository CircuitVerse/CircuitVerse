# frozen_string_literal: true

require "rails_helper"

RSpec.describe AboutPageComponents::TeamSectionComponent, type: :component do
  include ViewComponent::TestHelpers

  let(:sample_members) do
    [
      { name: "John Doe", img: "https://example.com/john.jpg", link: "https://github.com/johndoe" },
      { name: "Jane Smith", img: "https://example.com/jane.jpg", link: "https://github.com/janesmith" }
    ]
  end

  let(:title) { "Test Team" }
  let(:description) { "This is a test team description" }

  describe "rendering" do
    it "renders the component with title and description" do
      render_inline(described_class.new(
                      title: title,
                      description: description,
                      members: sample_members
                    ))

      expect(page).to have_css(".container")
      expect(page).to have_css("h2.main-heading", text: title)
      expect(page).to have_css("p.main-description", text: description)
      expect(page).to have_css(".teams-section")
    end

    it "renders all team members" do
      render_inline(described_class.new(
                      title: title,
                      description: description,
                      members: sample_members
                    ))

      sample_members.each do |member|
        expect(page).to have_css(".team-member-container")
        expect(page).to have_css("a[href='#{member[:link]}']")
        expect(page).to have_css("img[src='#{member[:img]}']")
        expect(page).to have_css("p.team-footer", text: member[:name])
      end
    end
  end
end
