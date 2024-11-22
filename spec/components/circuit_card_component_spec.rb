# frozen_string_literal: true

require "rails_helper"

RSpec.describe CircuitCardComponent, type: :component do
  let(:user) { FactoryBot.create(:user) }
  let(:circuit) { create(:project) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  it "renders the circuit card with correct content" do
    render_inline(described_class.new(circuit: circuit))

    expect(page).to have_css(".card.circuit-card")
    expect(page).to have_css("img.card-img-top.circuit-card-image[alt='#{circuit.name}']")
    expect(page).to have_css(".circuit-card-name p", text: circuit.name)
    expect(page).to have_css(".circuit-card-name .tooltiptext", text: circuit.name)
    expect(page).to have_link(I18n.t("view"))
  end
end
