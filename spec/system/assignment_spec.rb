# frozen_string_literal: true

require "rails_helper"

describe "Assignments", type: :system do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
    @member = FactoryBot.create(:user)
    FactoryBot.create(:group_member, group: @group, user: @member)
  end

  context "when user is mentor" do
    it "should create assignment" do
      sign_in @mentor
      visit new_group_assignment_path(@group)

      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence

      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Assignment was successfully created.")

      click_link "Show"
      check_show_page(name, deadline, description, "Input, Button, Power")
    end

    it "should not create assignment when name is blank" do
      sign_in @mentor
      visit new_group_assignment_path(@group)

      name = nil
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence

      fill_assignments(name, deadline, description, grading: true)

      click_button "Create Assignment"
      expect(page).to have_text("Name is too short (minimum is 1 character)")
    end

    it "should be able to edit assignment" do
      sign_in @mentor
      @assignment = FactoryBot.create(:assignment, group: @group)
      visit edit_group_assignment_path(@group, @assignment)

      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 23)
      description = Faker::Lorem.sentence

      fill_assignments(name, deadline, description, grading: false)
      uncheck "checkbox-Power"

      click_button "Update Assignment"
      expect(page).to have_text("Assignment was successfully updated.")

      click_link "Show"
      check_show_page(name, deadline, description, "Input, Button")
    end
  end

  context "when user is a member" do
    it "should be able to make assignment project" do
      @assignment = FactoryBot.create(:assignment, group: @group)
      sign_in @member
      visit group_path(@group)
      click_on "Start Working"
      expect(page).to have_content(@member.name + "/" + @assignment.name)
    end
  end

  def fill_assignments(name, deadline, description, grading:)
    fill_in "Name", with: name
    fill_in "Deadline", with: deadline.strftime("%d/%m/%Y 12:00")
    sleep 0.1
    find("#assignment_deadline").send_keys :enter
    fill_in_editor ".trumbowyg-editor", with: description

    if :grading == true then
      select "percent", from: "assignment_grading_scale"
    end

    check "restrict-elements"
    check "checkbox-Input"
    check "checkbox-Button"
    check "checkbox-Power"
  end

  def fill_in_editor(editor, with:)
    find(editor).send_keys with
  end

  def check_show_page(name, deadline, description, restricted_elements)
    expect(page).to have_text(name)
    expect(page).to have_text(description)
    expect(page).to have_text(deadline.strftime("%d %b %Y"))
    expect(page).to have_text(restricted_elements)
  end
end
