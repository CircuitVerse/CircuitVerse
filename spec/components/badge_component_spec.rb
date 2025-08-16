# frozen_string_literal: true

require "rails_helper"

RSpec.describe Home::BadgeComponent, type: :component do
  include ViewComponent::TestHelpers

  it "renders badge with green dot by default" do
    rendered = render_inline(described_class.new(text: "Free and Open Source"))

    expect(rendered.css(".badge-container")).to be_present
    expect(rendered.css(".green-dot").text).to eq("•")
    expect(rendered.text).to include("Free and Open Source")
  end

  it "renders badge without green dot when should_show_dot is false" do
    rendered = render_inline(described_class.new(text: "Statistics", should_show_dot: false))

    expect(rendered.css(".badge-container")).to be_present
    expect(rendered.css(".green-dot")).to be_empty
    expect(rendered.text).to include("Statistics")
  end
end
