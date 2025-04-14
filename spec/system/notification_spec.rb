# frozen_string_literal: true

require "rails_helper"

describe "Notifcation", type: :system do
  include ActionView::Helpers::TranslationHelper

  before do
    @author = FactoryBot.create(:user)
    @user = sign_in_random_user
    @project = FactoryBot.create(:project, name: "Project", author: @author, project_access_type: "Public")
    driven_by(:selenium_chrome_headless)
  end

  it "initiate notification" do
    sign_in @user
    visit user_project_path(@author, @project)
    
    # Find and click the fork link
    fork_link = find_link(class: "btn primary-button projects-primary-button", text: /Fork/)
    fork_link.click
    
    # Wait for the notification to be created and delivered
    expect {
      # Wait for up to 5 seconds for the notification to be created
      Timeout.timeout(5) do
        sleep 0.1 until @author.noticed_notifications.count == 1
      end
    }.not_to raise_error
    
    # Verify notification content
    notification = @author.noticed_notifications.first
    expect(notification.to_notification.message).to include(@user.name)
    expect(notification.to_notification.message).to include(@project.name)
  end

  context "notification page" do
    before do
      sign_in @user
      visit user_project_path(@author, @project)
      
      # Find and click the fork link
      fork_link = find_link(class: "btn primary-button projects-primary-button", text: /Fork/)
      fork_link.click
      
      # Wait for the notification to be created and delivered
      expect {
        # Wait for up to 5 seconds for the notification to be created
        Timeout.timeout(5) do
          sleep 0.1 until @author.noticed_notifications.count == 1
        end
      }.not_to raise_error
      
      sign_in @author
      visit notifications_path(@author)
      
      # Wait for the page to load and notifications to be visible
      expect(page).to have_selector(".notification-div", wait: 10)
    end

    it "render all notifications" do
      # Verify notification content is displayed
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
      expect(page).to have_selector(".notification-div", count: 1)
    end

    it "render all unread notifications" do
      # Verify unread notifications tab exists and is clickable
      expect(page).to have_selector("#unread-notifications")
      page.find("#unread-notifications").click
      
      # Wait for the unread notifications to load and become visible
      expect(page).to have_selector("#unread-notifications-div:not(.d-none)", wait: 10)
      expect(page).to have_text("#{@user.name} forked your Project #{@project.name}")
    end

    it "mark all notifications as read" do
      # Verify mark all as read link exists and is clickable
      mark_all_as_read_text = t("users.notifications.mark_as_read_button")
      expect(page).to have_link(mark_all_as_read_text)
      
      # Click the link and wait for the request to complete
      page.find("a", text: mark_all_as_read_text).click
      
      # Wait for the notifications to be marked as read
      expect {
        # Wait for up to 5 seconds for the notification to be marked as read
        Timeout.timeout(5) do
          sleep 0.1 until @author.noticed_notifications.unread.count == 0
        end
      }.not_to raise_error
    end

    it "mark notification as read" do
      # Verify notification link exists and is clickable
      notification_text = "#{@user.name} forked your Project #{@project.name}"
      expect(page).to have_text(notification_text)
      
      # Find and click the notification link
      notification_link = find(".notification-div", text: notification_text)
      notification_link.click
      
      # Wait for the notification to be marked as read
      expect {
        # Wait for up to 5 seconds for the notification to be marked as read
        Timeout.timeout(5) do
          sleep 0.1 until @author.noticed_notifications.read.count == 1
        end
      }.not_to raise_error
    end
  end
end