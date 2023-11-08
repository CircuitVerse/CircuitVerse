# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe "GET #github" do
    context "when signup feature is enabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:signup).and_return(true)
      end

      it "does not redirect to sign in page" do
        get :github
        expect(response).not_to redirect_to(new_user_session_path)
      end
    end

    context "when signup feature is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:signup).and_return(false)
      end

      it "redirects to sign in page with an alert message" do
        get :github
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq("Signup is disabled for now")
      end
    end
  end
end
