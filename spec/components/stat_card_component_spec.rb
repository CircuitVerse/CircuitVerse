# frozen_string_literal: true

require "rails_helper"

RSpec.describe Home::StatCardComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders stat card with number and label" do
    rendered = render_inline(described_class.new(number: "1,234", label: "Circuits Created"))

    expect(rendered.css(".stat-card")).to be_present
    expect(rendered.css(".stat-number").text).to eq("1,234")
    expect(rendered.css(".stat-label").text).to eq("Circuits Created")
  end
end
