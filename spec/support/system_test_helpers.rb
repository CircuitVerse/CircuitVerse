# frozen_string_literal: true

module SystemTestHelpers
  def system_sign_in(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123" # Assuming user.password is set by factory
    click_button "Log in"
  end
end
