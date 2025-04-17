require "rails_helper"

RSpec.describe "groups/_delete_member_confirmation_modal", type: :view do
  it "renders delete member modal" do
    render partial: "groups/delete_member_confirmation_modal"

    expect(rendered).to have_css("#deletememberModal")
    expect(rendered).to have_text(I18n.t("groups.remove_member_message"))
    expect(rendered).to have_link(I18n.t("delete"))
    expect(rendered).to have_css("#groups-member-delete-button")
  end
end
