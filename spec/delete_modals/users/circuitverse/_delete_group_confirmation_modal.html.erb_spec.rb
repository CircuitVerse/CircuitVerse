# frozen_string_literal: true

require "rails_helper"

RSpec.describe "users/circuitverse/_delete_group_confirmation_modal", type: :view do
  it "renders delete group modal" do
    render partial: "users/circuitverse/delete_group_confirmation_modal"

    expect(rendered).to have_css("#deletegroupModal")
    expect(rendered).to have_text(I18n.t("users.circuitverse.delete_group_confirmation"))
    expect(rendered).to have_link(I18n.t("delete"))
    expect(rendered).to have_css("#groups-group-delete-button")
  end
end
