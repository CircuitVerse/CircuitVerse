# frozen_string_literal: true

require "rails_helper"

describe "Settings", type: :system do
  before do
    @user = FactoryBot.create(:user)
  end

  it "should be able to enable 'hide navbar' option" do
    sign_in @user
    visit user_settings_path(@user)
    check "hide_external_navbar_links"
    expect(page).to have_no_link("Documentation", :href=>"https://docs.circuitverse.org/")
  end
end
