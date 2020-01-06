# frozen_string_literal: true

require "rails_helper"

describe "Assignments", type: :system do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  it 'should create assigment' do
    sign_in @mentor
    visit new_group_assignment_path(@group)
    
    name = Faker::Lorem.word
    deadline = Faker::Date.forward(days: 7)
    description = Faker::Lorem.sentence

    fill_in "Name", with: name
    fill_in_deadline "#party", date: deadline # TODO: will be changed when #778 will be merged
    fill_in_editor "#editor", with: description
    select 'percent', from: 'assignment_grading_scale'

    # TODO: not impelemented cause #778 is not merged
    # check 'restrict-elements'
    # check 'checkbox-Input'
    # check 'checkbox-Button'
    # check 'checkbox-Power'

    click_button "Create Assignment"

    expect(page).to have_text("Assignment was successfully created.")
    expect(page).to have_text(name)
    expect(page).to have_text(deadline.strftime("%d %b,%Y"))
  end

  def fill_in_editor(editor, with:)
    find(editor).send_keys with
  end

  def fill_in_deadline(field,date:)
    find(field).send_keys [date.strftime("%d%m%Y"),:arrow_right,"12:00"]
  end
end
