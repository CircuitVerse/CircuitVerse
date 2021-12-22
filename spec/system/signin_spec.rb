# frozen_string_literal: true

require "rails_helper"

describe "Sign In", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    @user = FactoryBot.create(:user)
  end

  before do
    visit "/users/sign_in"
  end

  it "does not sign-in when no credentials" do
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end

  it "sign-ins when valid credentials" do
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Log in"

    expect(page).to have_text("Signed in successfully.")
  end

  it "does not sign-in when password is empty" do
    fill_in "Email", with: @user.email
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end

  it "does not sign-in when email is empty" do
    fill_in "Password", with: @user.password
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end
end
