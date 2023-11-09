# frozen_string_literal: true

require "rails_helper"

describe "Group management", type: :system do
  let(:primary_mentor) { FactoryBot.create(:user) }
  let(:group) { FactoryBot.create(:group, primary_mentor: primary_mentor) }
  let(:user) { FactoryBot.create(:user) }
  let(:add_user_to_group_as_mentor) { GroupMember.create(group_id: group.id, user_id: user.id, mentor: true) }
  let(:add_user_to_group_as_member) { GroupMember.create(group_id: group.id, user_id: user.id, mentor: false) }

  before do
    group
    driven_by(:selenium_chrome_headless)
    login_as(primary_mentor, scope: :user)
  end

  after do
    Warden.test_reset!
  end

  it "creates a group" do
    visit "/groups/new"
    fill_in "group[name]", with: "Test"
    click_button "Save"

    expect(page).to have_text("Group was successfully created.")
  end

  it "does not create a group when name is blank" do
    visit "/groups/new"
    fill_in "group[name]", with: ""
    click_button "Save"

    expect(page).to have_text("Name is too short (minimum is 1 character)")
  end

  it "adds a member to the group" do
    visit "/groups/#{group.id}"
    click_button "+ Add Members"
    fill_in_input "#group_email_input", with: "example@gmail.com"
    fill_in_input "#group_email_input", with: :enter
    click_button "Add members"

    expect(page).to have_text(
      "Out of 1 Email(s), 1 was valid and 0 were invalid. 1 user(s) will be invited."
    )
  end

  it "removes a member from the group" do
    group.users.append(user)
    visit "/groups/#{group.id}"
    click_on "Remove"
    execute_script "document.getElementById('deletememberModal').style.display='block'"
    execute_script "document.getElementById('deletememberModal').style.opacity=1"
    click_on "Delete"

    expect(page).to have_text("Group member was successfully removed.")
  end

  it "changes the group name" do
    visit "/groups/#{group.id}"
    click_on "Edit"
    fill_in "group[name]", with: "Example group"
    click_on "Save"

    expect(page).to have_text("Group was successfully updated.")
  end

  it "deletes the group" do
    visit user_groups_path(primary_mentor)
    click_on "Delete"
    button = find(id: "groups-group-delete-button")
    button.click

    expect(page).to have_text("Group was successfully deleted.")
  end

  it "adds mentor" do
    visit "/groups/#{group.id}"
    click_button "+ Add Mentors"
    fill_in_input "#group_email_input_mentor", with: user.email
    fill_in_input "#group_email_input_mentor", with: :enter
    click_button "Add mentors"

    expect(page).to have_text(
      "Out of 1 Email(s), 1 was valid and 0 were invalid. 1 user(s) will be invited."
    )
  end

  it "removes mentor" do
    add_user_to_group_as_mentor
    visit "/groups/#{group.id}"
    click_on "Remove"
    execute_script "document.getElementById('deletememberModal').style.display='block'"
    execute_script "document.getElementById('deletememberModal').style.opacity=1"
    click_on "Delete"

    expect(page).to have_text("Group member was successfully removed.")
  end

  describe "changes group member role" do
    it "converts member to mentor" do
      add_user_to_group_as_member
      visit "/groups/#{group.id}"
      make_mentor_btn = find("a[data-target='#promote-member-modal']")
      make_mentor_btn.click
      execute_script "document.getElementById('promote-member-modal').style.display='block'"
      execute_script "document.getElementById('promote-member-modal').style.opacity=1"
      make_mentor_btn = find(id: "groups-member-promote-button")
      make_mentor_btn.click

      expect(page).to have_text("Group member was successfully updated.")
    end

    it "converts mentor to member" do
      add_user_to_group_as_mentor
      visit "/groups/#{group.id}"
      make_mentor_btn = find("a[data-target='#demote-member-modal']")
      make_mentor_btn.click
      execute_script "document.getElementById('demote-member-modal').style.display='block'"
      execute_script "document.getElementById('demote-member-modal').style.opacity=1"
      make_mentor_btn = find(id: "groups-member-demote-button")
      make_mentor_btn.click

      expect(page).to have_text("Group member was successfully updated.")
    end
  end

  def fill_in_input(input, with:)
    find(input).send_keys with
  end
end
