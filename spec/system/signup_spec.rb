# frozen_string_literal: true

require "rails_helper"

describe "Sign up", type: :system do
  before do
    driven_by(:selenium)
  end

  before(:each) do
    visit root_path
    click_link "Log In"
    click_link "Sign up"
  end

  it "should not sign-up when no credentials" do
    click_button "Sign up"

    expect(page).to have_text("Email can't be blank")
    expect(page).to have_text("Password can't be blank")
  end

  it "should not sign-up when password is empty" do
    within("#registerModal") do
      fill_in "Name", with: "user1"
      fill_in "Email", with: "user1@example.com"
    end
    click_button "Sign up"

    expect(page).to have_text("Password can't be blank")
  end

  it "should not sign-up when email is empty" do
    within("#registerModal") do
      fill_in "Name", with: "user1"
      fill_in "Password", with: "secret"
    end
    click_button "Sign up"

    expect(page).to have_text("Email can't be blank")
  end

  it "should not sign-up when password is less than 6 characters" do
    within("#registerModal") do
      fill_in "Name", with: "user1"
      fill_in "Password", with: "secr"
    end
    click_button "Sign up"

    expect(page).to have_text("Password is too short (minimum is 6 characters)")
  end


  it "should sign-up when valid credentials" do
    within("#registerModal") do
      fill_in "Name", with: "user1"
      fill_in "Email", with: "user1@example.com"
      fill_in "Password", with: "secret"
    end
    click_button "Sign up"

    expect(page).to have_text("user1")
  end
end
