# frozen_string_literal: true

require "rails_helper"

RSpec.describe Contest::PreviewModalComponent, type: :component do
  it "renders the modal with heading, iframe and 'More' button" do
    render_inline(described_class.new)

    expect(page).to have_css("#projectModal")
    expect(page).to have_css("h4.modal-title", text: "Preview Project")
    expect(page).to have_css("iframe#project-iframe-preview")
    expect(page).to have_link("More", href: "#", id: "project-more-button")
  end
end
