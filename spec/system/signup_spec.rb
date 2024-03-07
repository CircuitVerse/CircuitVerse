# frozen_string_literal: true

require "rails_helper"

describe "Sign up", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    visit "/users/sign_up"
  end

  it "GET signup page" do
    expect(page).to have_current_path("/users/sign_up")
  end

  it "does not sign-up when no credentials" do
    click_button "Sign up"

    expect(page).to have_text("Email can't be blank")
    expect(page).to have_text("Email is invalid")
    expect(page).to have_text("Password can't be blank")
    expect(page).to have_text("Name can't be blank")
  end

  it "does not sign-up when password is empty" do
    fill_in "Name", with: "user1"
    fill_in "Email", with: "user1@example.com"
    click_button "Sign up"

    expect(page).to have_text("Password can't be blank")
  end

  it "does not sign-up when email is empty" do
    fill_in "Name", with: "user1"
    fill_in "Password", with: "secret"
    click_button "Sign up"

    expect(page).to have_text("Email can't be blank")
  end

  it "does not sign-up when password is less than 6 characters" do
    fill_in "Name", with: "user1"
    fill_in "Password", with: "secr"
    click_button "Sign up"

    expect(page).to have_text("Password is too short (minimum is 6 characters)")
  end

  it "does not signup with special symbols" do
    fill_in "Name", with: "!@#$%^&"
    fill_in "Email", with: "user1@example.com"
    fill_in "Password", with: "secret"
    click_button "Sign up"

    expect(page).to have_text("Name can only contain letters and spaces")
  end

  it "does not sign-up when passwords do not match" do
    fill_in "Name", with: "user1"
    fill_in "Email", with: "user1@example.com"
    fill_in "Password", with: "secret"
    fill_in "Confirm Password", with: "differentsecret"
    click_button "Sign up"

    expect(page).to have_text("Password confirmation doesn't match Password")
  end

  it "does sign-up when valid credentials" do
    fill_in "Name", with: "user"
    fill_in "Email", with: "user1@example.com"
    fill_in "Password", with: "secret"
    fill_in "Confirm Password", with: "secret" # Add this line
    click_button "Sign up"

    expect(page).to have_text("Welcome! You have signed up successfully.")
  end
end
