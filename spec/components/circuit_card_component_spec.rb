# frozen_string_literal: true

require "rails_helper"

RSpec.describe CircuitCardComponent, type: :component do
  let(:circuit) { create(:project) }  
  let(:current_user) { create(:user) }

  it "renders the circuit card with correct content" do
    render_inline(CircuitCardComponent.new(circuit: circuit, current_user: current_user))

    expect(page).to have_css(".card.circuit-card")
    expect(page).to have_css("img.card-img-top.circuit-card-image[alt='#{circuit.name}']")
    expect(page).to have_css(".circuit-card-name p", text: circuit.name)
    expect(page).to have_css(".circuit-card-name .tooltiptext", text: circuit.name)
    expect(page).to have_link(I18n.t("view"))
  end

  it "calls project_image_preview helper with correct arguments" do
    component = CircuitCardComponent.new(circuit: circuit, current_user: current_user)
    allow(component).to receive(:helpers).and_return(double(project_image_preview: "path/to/image.jpg"))
    
    expect(component.helpers).to receive(:project_image_preview).with(circuit, current_user)
    
    component.image_path
  end
end