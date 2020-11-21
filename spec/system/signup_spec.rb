# frozen_string_literal: true

require "rails_helper"

describe "Sign up", type: :system do
  before do
    driven_by(:selenium)
  end

  before(:each) do
    visit "/users/sign_up"
  end

  it "do not sign-up when name is invalid" do
    fill_in "Name", with: "user@123"
    fill_in "Email", with: "user1@example.com"
    fill_in "Password", with: "secret"
    click_button "Sign up"

    expect(page).to have_text("Name :only alphabets and spaces are allowed")
  end

  it "should not sign-up when password is less than 6 characters" do
    fill_in "Name", with: "user"
    fill_in "Email", with: "user1@example.com"
    fill_in "Password", with: "secr"
    click_button "Sign up"

    expect(page).to have_text("Password is too short (minimum is 6 characters)")
  end

  it "should sign-up when valid credentials" do
    fill_in "Name", with: "user"
    fill_in "Email", with: "user1@example.com"
    fill_in "Password", with: "secret"
    click_button "Sign up"

    expect(page).to have_text("Welcome! You have signed up successfully.")
  end
end
