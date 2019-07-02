# frozen_string_literal: true

require "rails_helper"

describe GradePolicy do
  subject { GradePolicy.new(user, grade) }

  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
    @assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :letter,
      grades_finalized: false)
    @assignment_project = FactoryBot.create(:project, assignment: @assignment,
      author: FactoryBot.create(:user))
    @grade = FactoryBot.create(:grade, project: @assignment_project, grader: @mentor,
      grade: "A", assignment: @assignment)
  end

  let(:grade) { @grade }

  context "user is mentor and grades have not been finalized" do
    let(:user) { @mentor }
    it { should permit(:mentor) }
  end

  # context "user is mentor but grades have been finalized" do
  #   let(:user) { @mentor }

  #   before do
  #     @assignment.grades_finalized = true
  #     @assignment.save
  #   end

  #   it { should_not permit(:mentor) }
  # end

  context "user is random" do
    let(:user) { FactoryBot.create(:user) }
    it { should_not permit(:mentor) }
  end
end
