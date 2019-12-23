# frozen_string_literal: true

require "rails_helper"

describe "Sign In", type: :system do
  before do
    driven_by(:selenium)
    @user = FactoryBot.create(:user)
  end

  before(:each) do
    visit "/users/sign_in"
  end

  it "should not sign-in when no credentials" do
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end

  it "should sign-in when valid credentials" do
    fill_in "user[email]", with: @user.email
    fill_in "user[password]", with: @user.password
    click_button "Log in"

    expect(page).to have_text("Signed in successfully.")
  end

  it "should not sign-in when password is empty" do
    fill_in "user[email]", with: @user.email
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end

  it "should not sign-in when email is empty" do
    fill_in "user[password]", with: @user.password
    click_button "Log in"

    expect(page).to have_text("Invalid Email or password.")
  end
end
