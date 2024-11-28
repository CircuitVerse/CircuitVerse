# frozen_string_literal: true

require "rails_helper"

describe StarsController, type: :request do
  before do
    @user = create(:user)
    @project = create(:project, author: create(:user))
    sign_in @user
  end

  describe "#create" do
    it "creates a star" do
      expect do
        post stars_path, params: { star: { user_id: @user.id, project_id: @project.id } }
      end.to change(Star, :count).by(1)
    end
  end

  describe "#destroy" do
    before do
      @star = create(:star, project: @project, user: @user)
    end

    it "destroys a star" do
      expect do
        delete star_path(@star)
      end.to change(Star, :count).by(-1)
    end
  end
end
