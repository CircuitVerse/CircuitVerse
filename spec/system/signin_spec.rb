# frozen_string_literal: true

require "rails_helper"

describe "Sign In", type: :system do
  before do
    # Ensure we're using the headless Selenium driver (so we have a real browser):
    driven_by(:selenium_chrome_headless)

    # Create a user with FactoryBot for testing sign-in
    @user = FactoryBot.create(:user)

    # Visit the sign-in page
    visit "/users/sign_in"
  end

  it "does not sign-in when no credentials" do
    # Attempt to log in without entering email or password
    click_button "Log in"

    # Percy snapshot here to see the error state
    page.percy_snapshot("Sign In - No Credentials")

    expect(page).to have_text("Invalid Email or password.")
  end

  it "sign-ins when valid credentials" do
    fill_in "Email", with: @user.email
    fill_in "Password", with: @user.password
    click_button "Log in"

    # Percy snapshot after successful sign-in
    page.percy_snapshot("Sign In - Success")

    expect(page).to have_text("Signed in successfully.")
  end

  it "does not sign-in when password is empty" do
    fill_in "Email", with: @user.email
    click_button "Log in"

    # Percy snapshot of the invalid password state
    page.percy_snapshot("Sign In - Empty Password")

    expect(page).to have_text("Invalid Email or password.")
  end

  it "does not sign-in when email is empty" do
    fill_in "Password", with: @user.password
    click_button "Log in"

    # Percy snapshot of the invalid email state
    page.percy_snapshot("Sign In - Empty Email")

    expect(page).to have_text("Invalid Email or password.")
  end
end
