# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomepageComponents::HomeButtonComponent, type: :component do
  it "renders the button with correct text and path" do
    render_inline(described_class.new(path: "/teachers", text_key: "circuitverse.index.for_teachers"))

    expect(page).to have_link(I18n.t("circuitverse.index.for_teachers"), href: "/teachers")
    expect(page).to have_css("a.btn.tertiary-button")
  end
end