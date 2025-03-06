# frozen_string_literal: true

require "rails_helper"

RSpec.describe HomeMainContentComponent, type: :component do
  it "renders the main heading" do
    render_inline(HomeMainContentComponent.new)

    expect(page).to have_text(I18n.t("circuitverse.index.main_heading"))
  end

  it "renders the main description" do
    render_inline(HomeMainContentComponent.new)

    expect(page).to have_text(I18n.t("circuitverse.index.main_description"))
  end

  it "renders the launch simulator button" do
    render_inline(HomeMainContentComponent.new)

    expect(page).to have_link(I18n.t("launch_simulator"), href: "/simulator")
  end

  it "renders the learn logic design link" do
    render_inline(HomeMainContentComponent.new)

    expect(page).to have_link(I18n.t("circuitverse.index.learn_logic_design"), href: "https://learn.circuitverse.org/")
  end
end
 



