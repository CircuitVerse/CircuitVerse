# frozen_string_literal: true

require "rails_helper"

describe "Notifications", type: :system do
  describe "fork_notification" do
    before do
      @author = FactoryBot.create(:user)
      @user = sign_in_random_user
      @project = FactoryBot.create(:project, name: "Project", author: @author, project_access_type: "Public")
      driven_by(:selenium_chrome_headless)
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

  describe "new_collaborator_notification" do
    before do
      @author = FactoryBot.create(:user)
      @user = sign_in_random_user
      @project = FactoryBot.create(:project, name: "Project", author: @author, project_access_type: "Public")
      driven_by(:selenium_chrome_headless)
    end

    it "initiate notification" do
      email = @user.email
      sign_in @author
      visit user_project_path(@author, @project)
      click_on "+ Add a Collaborator"
      project_input_field_id = "#project_email_input_collaborator"
      fill_in_input project_input_field_id, with: email
      fill_in_input project_input_field_id, with: :enter
      click_on "Add Collaborators"
      expect(page).to have_text("1 user(s) will be invited")
    end

    context "notification page" do
      before do
        email = @user.email
        sign_in @author
        visit user_project_path(@author, @project)
        click_on "+ Add a Collaborator"
        project_input_field_id = "#project_email_input_collaborator"
        fill_in_input project_input_field_id, with: email
        fill_in_input project_input_field_id, with: :enter
        click_on "Add Collaborators"
        sign_in @user
        visit notifications_path(@user)
      end

      it "render all notifications" do
        expect(page).to have_text("You have been added as a collaborator in #{@project.name} by #{@author.name}")
      end

      it "render all unread notifications" do
        page.find("#unread-notifications").click
        expect(page).to have_text("You have been added as a collaborator in #{@project.name} by #{@author.name}")
      end

      it "mark all notifications as read" do
        click_on "Mark all as read"
        expect(@user.noticed_notifications.unread.count).to eq(0)
      end

      it "mark notification as read" do
        click_on "You have been added as a collaborator in #{@project.name} by #{@author.name}"
        expect(@user.noticed_notifications.read.count).to eq(1)
      end
    end

    def fill_in_input(editor, with:)
      find(editor).send_keys with
    end
  end
end
