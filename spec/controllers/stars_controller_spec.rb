# frozen_string_literal: true

require "rails_helper"

describe StarsController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: FactoryBot.create(:user))
    sign_in @user
  end

  describe "#create" do
    context "when user is authenticated" do
      it "creates a star for the current user" do
        expect do
          post stars_path, params: { star: { project_id: @project.id } }
        end.to change(Star, :count).by(1)
        expect(Star.last.user_id).to eq(@user.id)
      end

      it "ignores user_id param and uses current_user instead (IDOR protection)" do
        other_user = FactoryBot.create(:user)
        expect do
          post stars_path, params: { star: { user_id: other_user.id, project_id: @project.id } }
        end.to change(Star, :count).by(1)
        # Verify the star was created for current_user, NOT the spoofed user_id
        expect(Star.last.user_id).to eq(@user.id)
        expect(Star.last.user_id).not_to eq(other_user.id)
      end
    end

    context "when user is not authenticated" do
      it "requires authentication" do
        sign_out @user
        post stars_path, params: { star: { project_id: @project.id } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "#destroy" do
    context "when user owns the star" do
      before do
        @star = FactoryBot.create(:star, project: @project, user: @user)
      end

      it "destroys the star" do
        expect do
          delete star_path(@star)
        end.to change(Star, :count).by(-1)
      end
    end

    context "when user does not own the star (IDOR protection)" do
      before do
        other_user = FactoryBot.create(:user)
        @other_star = FactoryBot.create(:star, project: @project, user: other_user)
      end

      it "returns not found and does not delete the star" do
        expect do
          delete star_path(@other_star)
        end.not_to change(Star, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user is not authenticated" do
      before do
        @star = FactoryBot.create(:star, project: @project, user: @user)
      end

      it "requires authentication" do
        sign_out @user
        delete star_path(@star)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
