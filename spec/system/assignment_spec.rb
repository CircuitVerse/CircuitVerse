# frozen_string_literal: true

require "rails_helper"

describe "Assignments", type: :system do
  let(:primary_mentor) { FactoryBot.create(:user, confirmed_at: Time.zone.now) }
  let!(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }

  let(:mentor) do
    FactoryBot.create(:user, confirmed_at: Time.zone.now).tap do |user|
      FactoryBot.create(:group_member, group: group, user: user, mentor: true)
    end
  end

  let(:member) do
    FactoryBot.create(:user, confirmed_at: Time.zone.now).tap do |user|
      FactoryBot.create(:group_member, group: group, user: user)
    end
  end

  let(:assignment) { FactoryBot.create(:assignment, group: group) }
  let(:closed_assignment) { FactoryBot.create(:assignment, group: group, status: "closed") }

  before do
    driven_by(:playwright)
  end

  context "when user is primary_mentor" do
    before { sign_in primary_mentor }

    it "creates assignment" do
      visit new_group_assignment_path(group)
      name = "TestAssignment#{SecureRandom.hex(3)}"
      deadline = Time.zone.parse("2025-12-31 12:00")
      description = "Assignment description for mentor"

      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Assignment was successfully created.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button, Power")
    end

    it "deletes assignment" do
      assignment
      visit group_path(group)
      click_link "Delete"
      find("#groups-assignment-delete-button").click
      expect(page).to have_text("Assignment was successfully deleted.")
    end

    it "does not create assignment when name is blank" do
      visit new_group_assignment_path(group)
      deadline = Time.zone.parse("2025-12-31 12:00")
      description = "No name assignment"

      fill_assignments(nil, deadline, description, grading: true)
      click_button "Create Assignment"

      expect(page).to have_text("Name is too short (minimum is 1 character)")
    end

    it "can edit assignment when assignment is not closed" do
      visit edit_group_assignment_path(group, assignment)
      name = "EditedAssignment#{SecureRandom.hex(2)}"
      deadline = Time.zone.parse("2026-01-10 12:00")
      description = "Updated description"
      fill_assignments(name, deadline, description, grading: false)
      page.find("#label-Power").click

      click_button "Update Assignment"
      expect(page).to have_text("Assignment was successfully updated.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button")
    end

    it "cannot edit assignment when it is closed" do
      visit edit_group_assignment_path(group, closed_assignment)
      expect(page).to have_text("You are not authorized to do the requested operation")
    end

    it "can close assignment" do
      assignment
      visit group_path(group)
      click_link "Close"
      visit group_path(group)
      expect(page).to have_text("Reopen")
    end

    it "can reopen assignment" do
      closed_assignment
      visit group_path(group)
      click_link "Reopen"
      visit group_path(group)
      expect(page).to have_text("Close")
    end
  end

  context "when user is mentor" do
    before { sign_in mentor }

    it "creates assignment" do
      visit new_group_assignment_path(group)
      name = "MentorAssignment#{SecureRandom.hex(3)}"
      deadline = Time.zone.parse("2025-12-15 12:00")
      description = "Mentor's assignment"

      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Assignment was successfully created.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button, Power")
    end

    it "deletes assignment" do
      assignment
      visit group_path(group)
      click_link "Delete"
      find("#groups-assignment-delete-button").click
      expect(page).to have_text("Assignment was successfully deleted.")
    end

    it "does not create assignment when name is blank" do
      visit new_group_assignment_path(group)
      deadline = Time.zone.parse("2025-12-20 12:00")
      description = "Invalid assignment"

      fill_assignments(nil, deadline, description, grading: true)
      click_button "Create Assignment"

      expect(page).to have_text("Name is too short (minimum is 1 character)")
    end

    it "can edit assignment when not closed" do
      visit edit_group_assignment_path(group, assignment)
      name = "MentorEdit#{SecureRandom.hex(2)}"
      deadline = Time.zone.parse("2026-02-01 12:00")
      description = "Mentor edit description"
      fill_assignments(name, deadline, description, grading: false)
      page.find("#label-Power").click

      click_button "Update Assignment"
      expect(page).to have_text("Assignment was successfully updated.")

      click_link "View"
      check_show_page(name, deadline, description, "Input, Button")
    end

    it "cannot edit closed assignment" do
      visit edit_group_assignment_path(group, closed_assignment)
      expect(page).to have_text("You are not authorized to do the requested operation")
    end

    it "cannot close assignment" do
      assignment
      visit group_path(group)
      click_link "Close"
      expect(page).to have_text("You are not authorized to do the requested operation")
    end

    it "can reopen assignment" do
      closed_assignment
      visit group_path(group)
      click_link "Reopen"
      visit group_path(group)
      expect(page).to have_text("Close")
    end
  end

  context "when user is a member" do
    before { sign_in member }

    it "can make assignment project" do
      assignment
      visit group_path(group)
      click_on "Start Working"
      expect(page).to have_content("#{member.name}/#{assignment.name}")
    end
  end

  def fill_assignments(name, deadline, description, grading:)
    fill_in "Name", with: name unless name.nil?
    fill_in "Deadline", with: deadline.strftime("%d/%m/%Y 12:00")
    expect(page).to have_selector("#assignment_deadline", visible: true)
    find("#assignment_deadline", visible: true).send_keys :enter
    fill_in_editor ".trumbowyg-editor", with: description

    select "Percent(1-100)", from: "assignment_grading_scale" if grading
    page.find("#label-restrict-elements").click
    page.find("#label-Input").click
    page.find("#label-Button").click
    page.find("#label-Power").click
  end

  def fill_in_editor(selector, with:)
    find(selector).send_keys with
  end

  def check_show_page(name, deadline, description, restricted_elements)
    expect(page).to have_text(name)
    expect(page).to have_text(description)
    expect(page).to have_text(deadline.strftime("%a %b %d %Y"))
    expect(page).to have_text(restricted_elements)
  end
end
