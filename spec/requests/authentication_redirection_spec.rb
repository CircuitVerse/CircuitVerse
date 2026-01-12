require "rails_helper"

RSpec.describe "Authentication Redirection", type: :request do
  describe "POST /users/sign_in" do
    let(:user) { create(:user) }

    it "redirects to the user's dashboard (projects page) after successful login" do
      post user_session_path, params: { user: { email: user.email, password: "password123" } }
      expect(response).to redirect_to(user_projects_path(user))
    end
  end
end
