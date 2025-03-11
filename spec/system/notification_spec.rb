# frozen_string_literal: true

require "rails_helper"
require "active_job/test_helper"

describe "Notifcation", type: :system do
  include ActiveJob::TestHelper
  attr_reader :author, :user, :project

  before do
    author_user = FactoryBot.create(:user)
    random_user = sign_in_random_user
    test_project = FactoryBot.create(:project, name: "Project", author: author_user, project_access_type: "Public")

    @user    = random_user
    @author  = author_user
    @project = test_project

    driven_by(:selenium_chrome_headless)
  end

  it "initiate notification" do
    sign_in user
    visit user_project_path(author, project)

    # Inline background check: we expect the author's notification count to change by 1
    expect do
      perform_enqueued_jobs do
        click_on "Fork"
      end
    end.to change { author.noticed_notifications.count }.by(1)
  end

  context "notification page" do
    before do
      sign_in user
      visit user_project_path(author, project)
      perform_enqueued_jobs do
        click_on "Fork"
      end

      sign_in author
      visit notifications_path(author)
    end

    it "render all notifications" do
      expect(page).to have_text("#{user.name} forked your Project #{project.name}")
    end

    it "render all unread notifications" do
      expect(page).to have_selector("#unread-notifications")
      page.find("#unread-notifications").click
      expect(page).to have_text("#{user.name} forked your Project #{project.name}")
    end

    it "mark all notifications as read" do
      expect(page).to have_link("Mark all as read")
      click_on "Mark all as read"
      expect(author.noticed_notifications.unread.count).to eq(0)
    end

    it "mark notification as read" do
      expect(page).to have_link("#{user.name} forked your Project #{project.name}")
      click_on "#{user.name} forked your Project #{project.name}"
      expect(author.noticed_notifications.read.count).to eq(1)
    end
  end
end
