# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizations translations", type: :request do
  let(:user) { create(:user) }

  before do
    Flipper.enable(:organizations)
    sign_in user
  end

  it "renders the translated Organizations link in the header dropdown" do
    get root_path
    expect(response.body).to include(I18n.t("layout.header.link_to_organizations"))
    expect(response.body).not_to include("translation missing: en.layout.header.organizations")
  end

  it "renders the translated Cancel button on the organization form" do
    get new_organization_path
    expect(response.body).to include(I18n.t("organizations.form.cancel"))
    expect(response.body).not_to include("translation missing: en.cancel")
  end
end
