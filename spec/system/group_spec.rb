# frozen_string_literal: true

require "rails_helper"

describe "Group management", type: :system do
  before(:all) do
    @user = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @user)
  end

  before(:each) do
    driven_by(:selenium)
    login_as(@user, scope: :user)
  end

  after(:each) do
    Warden.test_reset!
  end

  it "should create a group" do
    visit "/groups/new"
    fill_in "group[name]", with: "Test"
    click_button "Save"

    expect(page).to have_text("Group was successfully created.")
  end

  it "should not create a group when name is blank" do
    visit "/groups/new"
    fill_in "group[name]", with: ""
    click_button "Save"

    expect(page).to have_text("Name is too short (minimum is 1 character)")
  end

  it "should add a member to the group" do
    visit "/groups/#{@group.id}"
    click_button "+ Add Members"
    execute_script "document.getElementById('addmemberModal').style.display='block'"
    execute_script "document.getElementById('addmemberModal').style.opacity=1"
    fill_in "emails", with: @user2.email
    click_button "Add members"

    expect(page).to have_text(
      "Out of 1 Email(s), 1 was valid and 0 were invalid. 1 user(s) will be invited."
    )
  end

  it "should remove a member from the group" do
    @group.users.append(@user2)
    visit "/groups/#{@group.id}"
    click_on "Remove"
    execute_script "document.getElementById('deletememberModal').style.display='block'"
    execute_script "document.getElementById('deletememberModal').style.opacity=1"
    click_on "Delete"


    expect(page).to have_text("Group member was successfully removed.")
  end

  it "should change the group name" do
    visit "/groups/#{@group.id}"
    click_on "Edit"
    fill_in "group[name]", with: "Example group"
    click_on "Save"

    expect(page).to have_text("Group was successfully updated.")
  end
end
