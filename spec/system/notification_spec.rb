# frozen_string_literal: true

require "rails_helper"
include Warden::Test::Helpers

describe "Notification", type: :system do
  before(:all) do
    Warden.test_mode!
  end

  after(:all) do
    Warden.test_reset!
  end

  before do
    @author = FactoryBot.create(:user)
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(
      :project,
      name: "Project",
      author: @author,
      project_access_type: "Public"
    )
  end

  it "initiates notification" do
    login_as(@user, scope: :user)
    visit user_project_path(@author, @project)
    click_on "Fork"
    expect(@author.noticed_notifications.count).to eq(1)
  end

  context "notification page" do
    before do
      login_as(@user, scope: :user)
      visit user_project_path(@author, @project)
      click_on "Fork"

      login_as(@author, scope: :user)
      visit notifications_path(@author)
    end

    it "renders all notifications" do
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "renders all unread notifications" do
      page.find("#unread-notifications").click
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "marks all notifications as read" do
      click_on "Mark all as read"
      expect(@author.noticed_notifications.unread.count).to eq(0)
    end

    it "marks notification as read" do
      click_on "#{@user.name} forked your Project #{@project.name}"
      expect(@author.noticed_notifications.read.count).to eq(1)
    end
  end
end
