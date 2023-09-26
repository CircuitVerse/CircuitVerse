# frozen_string_literal: true

require "rails_helper"

describe StarsController do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: FactoryBot.create(:user))
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
      @star = FactoryBot.create(:star, project: @project, user: @user)
    end

    it "destroys a star" do
      expect do
        delete star_path(@star)
      end.to change(Star, :count).by(-1)
    end
  end
end
