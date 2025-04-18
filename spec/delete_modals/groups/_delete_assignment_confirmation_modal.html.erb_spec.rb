# frozen_string_literal: true
require "rails_helper"

RSpec.describe "groups/_delete_assignment_confirmation_modal", type: :view do
  it "renders delete assignment modal" do
    render partial: "groups/delete_assignment_confirmation_modal"

    expect(rendered).to have_css("#deleteassignmentModal")
    expect(rendered).to have_text(I18n.t("groups.remove_assignment_message"))
    expect(rendered).to have_link(I18n.t("delete"))
    expect(rendered).to have_css("#groups-assignment-delete-button")
  end
end