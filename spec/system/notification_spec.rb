# frozen_string_literal: true

require "rails_helper"

describe "Notifcation", type: :system do
  before do
    @author = FactoryBot.create(:user, name: "AuthorUser", email: "author@cv.com")
    @user = FactoryBot.create(:user, name: "ForkUser", email: "fork@cv.com")
    @project = FactoryBot.create(:project, name: "Project", author: @author, project_access_type: "Public")
    driven_by(:selenium_chrome_headless)
    Capybara.current_session.driver.browser.manage.window.resize_to(1920, 1080)
  end

  it "initiate notification" do
    sign_in @user
    visit user_project_path(@author, @project)
    click_on "Fork"
    expect(@author.noticed_notifications.count).to eq(1)
  end

  context "notification page" do
    before do
      sign_in @user
      visit user_project_path(@author, @project)
      click_on "Fork"
      sign_in @author
      visit notifications_path(@author)
      Capybara.current_session.driver.browser.manage.window.resize_to(1920, 1080)
    end

    it "render all notifications" do
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "render all unread notifications" do
      page.find("#unread-notifications").click
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "mark all notifications as read" do
      click_on "Mark all as read"
      expect(@author.noticed_notifications.unread.count).to eq(0)
    end

    it "mark notification as read" do
      click_on "#{@user.name} forked your Project #{@project.name}"
      expect(@author.noticed_notifications.read.count).to eq(1)
    end
  end
end
