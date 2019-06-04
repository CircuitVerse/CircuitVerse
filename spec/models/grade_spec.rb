# frozen_string_literal: true

require "rails_helper"

RSpec.describe Grade, type: :model do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
    @assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :letter)
    @assignment_project = FactoryBot.create(:project, assignment: @assignment,
      author: FactoryBot.create(:user))
  end

  describe "associations" do
    it { should belong_to(:project) }
    it { should belong_to(:grader) }
    it { should belong_to(:assignment) }
  end

  describe "validations" do
    before do
      @grade = FactoryBot.build(:grade, project: @assignment_project, grader: @mentor,
          grade: "A", assignment: @assignment)
    end

    context "grading scale" do
      it "valides grading scale" do
        expect(@grade).to be_valid
        @grade.grade = "199"
        expect(@grade).to be_invalid
      end
    end

    context "assignment and project" do
      it "valides assignment and project relations" do
        expect(@grade).to be_valid
        @assignment_project.assignment = FactoryBot.create(:assignment, group: @group)
        @assignment_project.save
        expect(@grade).to be_invalid
      end
    end
  end
end
