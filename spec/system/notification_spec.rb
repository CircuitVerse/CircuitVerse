# frozen_string_literal: true

require "rails_helper"

describe "Notifcation", type: :system do
  before do
    @author = FactoryBot.create(:user)
    @user = sign_in_random_user
    @project = FactoryBot.create(:project, name: "Project", author: @author, project_access_type: "Public")
    driven_by(:selenium_chrome_headless)
  end

  it "initiate notification" do
    sign_in @user
    visit user_project_path(@author, @project)

    # Wrap the click in perform_enqueued_jobs so any background job for the
    # notification finishes before we check the notification count.
    perform_enqueued_jobs do
      click_on "Fork"
    end

    # We expect the author to have exactly one notification after the user forks
    # now we ensure the job has run)
    expect(author.noticed_notifications.count).to eq(1)
  end

  context "notification page" do
    before do
      # Also wrap 'Fork' in perform_enqueued_jobs so that the notification is created
      # before we switch to the author's account to view notifications.
      sign_in @user
      visit user_project_path(author, @project)
      perform_enqueued_jobs do
        click_on "Fork"
      end

      sign_in author
      visit notifications_path(author)
    end

    it "render all notifications" do
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "render all unread notifications" do
      # Ensure the unread-notifications element is on the page before clicking.
      expect(page).to have_selector("#unread-notifications")
      page.find("#unread-notifications").click

      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "mark all notifications as read" do
      # Wait for the link to appear (protects against timing issues).
      expect(page).to have_link("Mark all as read")
      click_on "Mark all as read"

      expect(author.noticed_notifications.unread.count).to eq(0)
    end

    it "mark notification as read" do
      # Wait for the exact link to appear before clicking it.
      expect(page).to have_link("#{@user.name} forked your Project #{@project.name}")
      click_on "#{@user.name} forked your Project #{@project.name}"

      expect(author.noticed_notifications.read.count).to eq(1)
    end
  end
end
