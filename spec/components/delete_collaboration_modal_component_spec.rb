# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectComponents::DeleteCollaborationModalComponent, type: :component do
  before do
    render_inline(described_class.new)
  end

  it "renders modal title" do
    have_title(I18n.t("delete"))
  end

  it "renders modal body" do
    have_text(I18n.t("projects.remove_collaborator_message"))
  end

  it "renders delete button" do
    have_link(id: "projects-collaboration-delete-button")
  end

  it "renders close button" do
    have_button(class: "close")
  end
end
