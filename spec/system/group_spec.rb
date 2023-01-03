# frozen_string_literal: true

require "rails_helper"

describe "Group management", type: :system do
  before do
    @user = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @user)
    driven_by(:selenium_chrome_headless)
    login_as(@user, scope: :user)
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
    visit "/groups/#{@group.id}"
    click_button "+ Add Members"
    execute_script "document.getElementById('addmemberModal').style.display='block'"
    execute_script "document.getElementById('addmemberModal').style.opacity=1"
    execute_script "document.getElementById('group_member_emails')\
.insertAdjacentHTML('beforeend', '<option>example@gmail.com</option>')"
    select "example@gmail.com", from: "group_member[emails][]"
    execute_script "document.getElementById('group_email_input').click()"
    click_button "Add members"

    expect(page).to have_text(
      "Out of 1 Email(s), 1 was valid and 0 were invalid. 1 user(s) will be invited."
    )
  end

  it "removes a member from the group" do
    @group.users.append(@user2)
    visit "/groups/#{@group.id}"
    click_on "Remove"
    execute_script "document.getElementById('deletememberModal').style.display='block'"
    execute_script "document.getElementById('deletememberModal').style.opacity=1"
    click_on "Delete"

    expect(page).to have_text("Group member was successfully removed.")
  end

  it "changes the group name" do
    visit "/groups/#{@group.id}"
    click_on "Edit"
    fill_in "group[name]", with: "Example group"
    click_on "Save"

    expect(page).to have_text("Group was successfully updated.")
  end
end
