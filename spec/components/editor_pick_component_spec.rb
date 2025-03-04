# frozen_string_literal: true


require "rails_helper"

RSpec.describe EditorPickComponent, type: :component do
  let(:featured_circuits) do
    [
      OpenStruct.new(
        name: "Logic Circuit",
        author: OpenStruct.new(name: "User1"),
        circuit_preview: double("CircuitPreview", attached?: false)
      ),
      OpenStruct.new(
        name: "Arithmetic Circuit",
        author: OpenStruct.new(name: "User2"),
        circuit_preview: double("CircuitPreview", attached?: false)
      )
    ]
  end

  let(:current_user) { double("User", flipper_id: "user_1")  }

  it "renders editor pick circuits" do
    render_inline(described_class.new(featured_circuits: featured_circuits, current_user: current_user))

    expect(page).to have_text(I18n.t("circuitverse.index.editor_picks.main_heading"))
    expect(page).to have_text(I18n.t("circuitverse.index.editor_picks.main_description"))
    expect(page).to have_text("Logic Circuit")
    expect(page).to have_text("Arithmetic Circuit")
  end
end


