# frozen_string_literal: true

require "rails_helper"

describe "Assignments", type: :system do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @member = FactoryBot.create(:user)
    FactoryBot.create(:group_member, group: @group, user: @member)
    FactoryBot.create(:group_member, group: @group, user: @mentor, mentor: true)
    driven_by(:selenium_chrome_headless)
  end

  context "when user is primary_mentor" do
    it "creates assignment" do
      sign_in @primary_mentor
      visit new_group_assignment_path(@group)
      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence
      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Assignment was successfully created.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button, Power")
    end

    it "delete assignment" do
      sign_in @primary_mentor
      FactoryBot.create(:assignment, group: @group)
      visit group_path(@group)
      click_link "Delete"
      delete_assignment_button = find(id: "groups-assignment-delete-button")
      delete_assignment_button.click
      expect(page).to have_text("Assignment was successfully deleted.")
    end

    it "does not create assignment when name is blank" do
      sign_in @primary_mentor
      visit new_group_assignment_path(@group)

      name = nil
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence

      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Name is too short (minimum is 1 character)")
    end

    it "is able to edit assignment when assignment is not closed" do
      sign_in @primary_mentor
      @assignment = FactoryBot.create(:assignment, group: @group)
      visit edit_group_assignment_path(@group, @assignment)
      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence
      fill_assignments(name, deadline, description, grading: false)
      page.find("#label-Power").click

      click_button "Update Assignment"
      expect(page).to have_text("Assignment was successfully updated.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button")
    end

    it "is not able to edit assignment when assignment is closed" do
      sign_in @primary_mentor
      @assignment = FactoryBot.create(:assignment, group: @group, status: "closed")
      visit edit_group_assignment_path(@group, @assignment)

      expect(page).to have_text("You are not authorized to do the requested operation")
    end

    it "is able to close assignment" do
      sign_in @primary_mentor
      FactoryBot.create(:assignment, group: @group)
      visit group_path(@group)
      click_link "Close"
      visit group_path(@group)
      expect(page).to have_text("Reopen")
    end

    it "is able to reopen assignment" do
      sign_in @primary_mentor
      FactoryBot.create(:assignment, group: @group, status: "closed")
      visit group_path(@group)
      click_link "Reopen"
      visit group_path(@group)
      expect(page).to have_text("Close")
    end
  end

  context "when user is mentor" do
    it "creates assignment" do
      sign_in @mentor
      visit new_group_assignment_path(@group)
      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence
      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Assignment was successfully created.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button, Power")
    end

    it "delete assignment" do
      sign_in @mentor
      FactoryBot.create(:assignment, group: @group)
      visit group_path(@group)
      click_link "Delete"
      delete_assignment_button = find(id: "groups-assignment-delete-button")
      delete_assignment_button.click
      expect(page).to have_text("Assignment was successfully deleted.")
    end

    it "does not create assignment when name is blank" do
      sign_in @mentor
      visit new_group_assignment_path(@group)

      name = nil
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence

      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Name is too short (minimum is 1 character)")
    end

    it "is able to edit assignment when assignment is not closed" do
      sign_in @mentor
      @assignment = FactoryBot.create(:assignment, group: @group)
      visit edit_group_assignment_path(@group, @assignment)
      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence
      fill_assignments(name, deadline, description, grading: false)
      page.find("#label-Power").click

      click_button "Update Assignment"
      expect(page).to have_text("Assignment was successfully updated.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button")
    end

    it "is not able to edit assignment when assignment is closed" do
      sign_in @mentor
      @assignment = FactoryBot.create(:assignment, group: @group, status: "closed")
      visit edit_group_assignment_path(@group, @assignment)

      expect(page).to have_text("You are not authorized to do the requested operation")
    end

    it "is not able to close assignment" do
      sign_in @mentor
      FactoryBot.create(:assignment, group: @group)
      visit group_path(@group)
      click_link "Close"
      expect(page).to have_text("You are not authorized to do the requested operation")
    end

    it "is able to reopen assignment" do
      sign_in @mentor
      FactoryBot.create(:assignment, group: @group, status: "closed")
      visit group_path(@group)
      click_link "Reopen"
      visit group_path(@group)
      expect(page).to have_text("Close")
    end
  end

  context "when user is a member" do
    it "is able to make assignment project" do
      @assignment = FactoryBot.create(:assignment, group: @group)
      sign_in @member
      visit group_path(@group)
      click_on "Start Working"
      expect(page).to have_content("#{@member.name}/#{@assignment.name}")
    end
  end

  def fill_assignments(name, deadline, description, grading:)
    fill_in "Name", with: name
    fill_in "Deadline", with: deadline.strftime("%d/%m/%Y 12:00")
    sleep(0.1)
    find("#assignment_deadline", visible: true).send_keys :enter
    fill_in_editor ".trumbowyg-editor", with: description

    select "Percent(1-100)", from: "assignment_grading_scale" if grading == true

    page.find("#label-restrict-elements").click
    page.find("#label-Input").click
    page.find("#label-Button").click
    page.find("#label-Power").click
  end

  def fill_in_editor(editor, with:)
    find(editor).send_keys with
  end

  def check_show_page(name, deadline, description, restricted_elements)
    expect(page).to have_text(name)
    expect(page).to have_text(description)
    expect(page).to have_text(deadline.strftime("%a %b %d %Y"))
    expect(page).to have_text(restricted_elements)
  end
end
