# frozen_string_literal: true

require "rails_helper"

describe "User profile", type: :system do
  before do
    @user = sign_in_random_user
    sign_in @user
    driven_by(:selenium_chrome_headless)
  end

  it "shows user profile" do
    visit user_path(@user)
    expect(page).to have_text(@user.name)
  end

  it "lets user edit name" do
    visit profile_edit_path(@user)
    name = Faker::Name.name
    fill_in "Name", with: name
    click_button "Save"
    expect(page).to have_text(name)
  end

  it "lets user edit country" do
    visit profile_edit_path(@user)
    country = "United States"
    select country, from: "Country"
    click_button "Save"
    expect(page).to have_text(country)
  end

  it "lets user edit educational institute" do
    visit profile_edit_path(@user)
    educational_institute = Faker::Educator.university
    fill_in "Educational institute", with: educational_institute
    click_button "Save"
    expect(page).to have_text(educational_institute)
  end

  it "lets user update locale" do
    visit profile_edit_path(@user)
    select "Hindi", from: "Locale"
    click_button "Save"
    expect(page).to have_text("देश")
  end
end
