# frozen_string_literal: true

require "rails_helper"

describe "Assignments", type: :system do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
    @member = FactoryBot.create(:user)
    FactoryBot.create(:group_member, group: @group, user: @member)
  end

  describe 'user is mentor' do
    it 'should create assignment' do
      sign_in @mentor
      visit new_group_assignment_path(@group)
      
      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 7)
      description = Faker::Lorem.sentence

      fill_assignments(name,deadline,description,grading: true)

      click_button "Create Assignment"

      expect(page).to have_text("Assignment was successfully created.")
      expect(page).to have_text(name)
      expect(page).to have_text(deadline.strftime("%d %b,%Y"))
    end

    it 'should edit assignment' do
      sign_in @mentor
      @assignment = FactoryBot.create(:assignment, group: @group)
      visit edit_group_assignment_path(@group,@assignment)
      
      name = Faker::Lorem.word
      deadline = Faker::Date.forward(days: 7)
      description = Faker::Lorem.sentence

      fill_assignments(name,deadline,description,grading: false)

      click_button "Update Assignment"

      expect(page).to have_text("Assignment was successfully updated.")
      expect(page).to have_text(name)
      expect(page).to have_text(deadline.strftime("%d %b,%Y"))
    end
  end
  
  describe 'user is member' do
    it 'should be able to make assignment project' do
      @assignment = FactoryBot.create(:assignment, group: @group)
      sign_in @member
      visit group_path(@group)
      click_on 'Start Working'
      expect(page).to have_content(@member.name + "/" + @assignment.name) 
    end
  end

  def fill_assignments(name,deadline,description,grading:)
    fill_in "Name", with: name
    fill_in_deadline "#party", date: deadline # TODO: will be changed when #778 will be merged
    fill_in_editor "#editor", with: description
    if :grading == true then
      select 'percent', from: 'assignment_grading_scale'
    end

    # TODO: not impelemented cause #778 is not merged
    # check 'restrict-elements'
    # check 'checkbox-Input'
    # check 'checkbox-Button'
    # check 'checkbox-Power'
  end

  def fill_in_editor(editor, with:)
    find(editor).send_keys with
  end

  def fill_in_deadline(field,date:)
    find(field).send_keys [date.strftime("%d%m%Y"),:arrow_right,"12:00"]
  end
end
