# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::UsersController, "#update", type: :request do
  describe "update a user" do
    let!(:user) { FactoryBot.create(:user) }

    context "when requested user does not exists" do
      before do
        get "/api/v1/users/0", as: :json
      end

      it "returns 404 :not_found and should have jsonapi errors" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when not authenticated" do
      before do
        patch "/api/v1/users/#{user.id}", params: { name: "Updated Name" }, as: :json
      end

      it "returns 401 :unauthorized and should have jsonapi errors" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but not as the user to be updated" do
      before do
        token = get_auth_token(user)
        random_user = FactoryBot.create(:user)
        patch "/api/v1/users/#{random_user.id}",
              params: { name: "Updated Name" },
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns 403 :forbidden and should have jsonapi errors" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as the user to be updated" do
      before do
        token = get_auth_token(user)
        patch "/api/v1/users/#{user.id}",
              params: { name: "Updated Name" },
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the updated user" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("user")
        expect(response.parsed_body["data"]["attributes"]["name"]).to eq("Updated Name")
      end
    end

    # There is a image data
    context "when authenticated as the user and update the profile picture", :skip_windows do
      before do
        token = get_auth_token(user)
        patch "/api/v1/users/#{user.id}",
              params: { profile_picture: fixture_file_upload("profile.png", "image/png") },
              headers: { Authorization: "Token #{token}", content_type: "multipart/form-data" }
      end

      it "returns the updated user" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("user")
        profile_picture = response.parsed_body["data"]["attributes"]["profile_picture"]
        expect(profile_picture).not_to eq("original/Default.jpg")
      end
    end

    context "when authenticated as the user and removes the uploaded picture" do
      before do
        # user having profile picture
        new_user = FactoryBot.create(:user)
        token = get_auth_token(new_user)
        patch "/api/v1/users/#{new_user.id}",
              params: { remove_picture: "1" },
              headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the updated user" do
        expect(response).to have_http_status(:accepted)
        expect(response).to match_response_schema("user")
        profile_picture = response.parsed_body["data"]["attributes"]["profile_picture"]
        expect(profile_picture).to be_nil
      end
    end
  end
end
