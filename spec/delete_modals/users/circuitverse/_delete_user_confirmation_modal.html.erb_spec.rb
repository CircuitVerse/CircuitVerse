# frozen_string_literal: true
require "rails_helper"

RSpec.describe "users/circuitverse/_delete_user_confirmation_modal", type: :view do
  it "renders delete user modal" do
    render partial: "users/circuitverse/delete_user_confirmation_modal"

    expect(rendered).to have_css("#deleteuserModal")
    expect(rendered).to have_text(I18n.t("users.circuitverse.delete_user_confirmation"))
    expect(rendered).to have_link(I18n.t("delete"))
    expect(rendered).to have_css("#users-user-delete-button")
  end
end