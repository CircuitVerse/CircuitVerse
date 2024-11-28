# frozen_string_literal: true

require "rails_helper"

describe GradePolicy do
  subject { described_class.new(user, grade) }

  before do
    @primary_mentor = create(:user)
    @group = create(:group, primary_mentor: @primary_mentor)
    @assignment = create(:assignment, group: @group, grading_scale: :letter,
                                      grades_finalized: false)
    @assignment_project = create(:project, assignment: @assignment,
                                           author: create(:user))
    @grade = create(:grade, project: @assignment_project, grader: @primary_mentor,
                            grade: "A", assignment: @assignment)
  end

  let(:grade) { @grade }

  context "when the user is primary_mentor and grades have not been finalized" do
    let(:user) { @primary_mentor }

    it { is_expected.to permit(:mentor) }
  end

  context "when the user is a mentor" do
    before do
      @mentor = create(:user)
      create(:group_member, group: @group, user: @mentor, mentor: true)
    end

    let(:user) { @mentor }

    it { is_expected.to permit(:mentor) }
  end

  # context "user is mentor but grades have been finalized" do
  #   let(:user) { @mentor }

  #   before do
  #     @assignment.grades_finalized = true
  #     @assignment.save
  #   end

  #   it { should_not permit(:mentor) }
  # end

  context "when the user is random" do
    let(:user) { create(:user) }

    it { is_expected.not_to permit(:mentor) }
  end
end
