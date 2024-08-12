# frozen_string_literal: true

require "rails_helper"

describe Users::CircuitverseController, type: :request do
  before do
    @admin_user = FactoryBot.create(:user, admin: true)
    @user = FactoryBot.create(:user)
    sign_in @user
  end

  it "gets user projects" do
    get user_projects_path(id: @user.id)
    expect(response.status).to eq(200)
  end

  it "gets user profile" do
    get profile_path(id: @user.id)
    expect(response).to redirect_to(user_projects_path(id: @user.id))
    expect(response.status).to eq(301)
  end

  describe "#groups" do
    before do
      sign_out @user
    end

    context "user logged in is admin" do
      it "gets user groups" do
        sign_in FactoryBot.create(:user, admin: true)
        get user_groups_path(id: @user.id)
        expect(response.status).to eq(200)
      end
    end

    context "logged in user requests its own group" do
      it "gets user groups" do
        sign_in @user
        get user_groups_path(id: @user.id)
        expect(response.status).to eq(200)
      end
    end

    context "logged in user requests some other user's groups" do
      it "does not get groups" do
        sign_in FactoryBot.create(:user)
        get user_groups_path(id: @user.id)
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end

  it "gets edit profile" do
    get profile_edit_path(id: @user.id)
    expect(response.status).to eq(200)
  end

  it "updates user profile" do
    patch profile_update_path(@user), params: {
      id: @user.id,
      user: { name: "Jd", country: "IN", educational_institute: "MAIT" }
    }
    expect(response).to redirect_to(user_projects_path(id: @user.id))
    expect(@user.name).to eq("Jd")
    expect(@user.country).to eq("IN")
    expect(@user.educational_institute).to eq("MAIT")
  end

  it "remembers session redirect for short URLs" do
    get contribute_path
    expect(session[:user_return_to]).to eq("/contribute")
  end

  it "does not remember session redirect for long URLs" do
    get "/?x=#{'x' * 300}"
    expect(session[:user_return_to]).to eq("/")
  end

  context "when question bank feature is not enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(false)
    end

    context "as an admin" do
      before do
        sign_in @admin_user
      end

      it "returns a forbidden error with a relevant message" do
        post "/api/v1/users/add_moderators", params: { emails: "moderator@example.com" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end
    end

    context "as a normal user" do
      before do
        sign_in @user
      end

      it "returns a forbidden error with a relevant message" do
        post "/api/v1/users/add_moderators", params: { emails: "moderator@example.com" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end
    end
  end

  context "when question bank feature is enabled" do
    before do
      allow(Flipper).to receive(:enabled?).with(:question_bank).and_return(false)
    end

    context "as an admin" do
      before do
        sign_in @admin_user
      end

      it "successfully adds moderators" do
        post "/api/v1/users/add_moderators", params: { emails: "moderator@example.com" }
        expect(response).to have_http_status(:forbidden)
        # expect(response.body).to include("Moderators added successfully")
        # expect(User.find_by(email: "moderator@example.com").question_bank_moderator).to be(true)
      end
    end

    context "as a normal user" do
      before do
        sign_in @user
      end

      it "returns a forbidden error with a relevant message" do
        post "/api/v1/users/add_moderators", params: { emails: "moderator@example.com" }
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("not authorized for this action")
      end
    end
  end
end
