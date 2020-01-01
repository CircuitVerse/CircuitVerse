# frozen_string_literal: true

require "rails_helper"

describe StarsController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: FactoryBot.create(:user))
    sign_in @user
  end

  describe "#create" do
    it "creates a star" do
      expect {
        post stars_path, params: { star: { user_id: @user.id, project_id: @project.id } }
      }.to change { Star.count }.by(1)
    end
  end

  describe "#destroy" do
    before do
      @star = FactoryBot.create(:star, project: @project, user: @user)
    end

    it "destroys a star" do
      expect {
        delete star_path(@star)
      }.to change { Star.count }.by(-1)
    end
  end

  describe "Activity Notification" do
    it "creates notification when project is starred" do
      @star = FactoryBot.create(:star, project: @project, user: @user)
      @project_author = @project.author
      expect(@project_author.notifications.unopened_only.count).to eq(0)

      @star.notify :users

      unopened_notifications = @project_author.notifications.unopened_only
      expect(unopened_notifications.count).to eq(1)
      expect(unopened_notifications.latest.notifiable).to eq(@star)
      expect(@star.printable_notifiable_name(@user))
          .to eq("starred your project \"#{@project.name}\"")
      expect(@star.star_notifiable_path)
          .to eq("/users/#{@project_author.id}/projects/#{@project.id}")
    end
  end
end
