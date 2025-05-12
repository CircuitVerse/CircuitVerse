# frozen_string_literal: true

require "rails_helper"

RSpec.describe "projects/_delete_collaboration_confirmation_modal", type: :view do
  it "renders delete collaboration modal" do
    render partial: "projects/delete_collaboration_confirmation_modal"

    expect(rendered).to have_css("#deletecollaborationModal")
    expect(rendered).to have_text(I18n.t("projects.remove_collaborator_message"))
    expect(rendered).to have_link(I18n.t("delete"))
    expect(rendered).to have_css("#projects-collaboration-delete-button")
  end
end
