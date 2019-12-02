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
    before do
      allow_any_instance_of(Grade).to receive(:assignment).and_return(@assignment)
    end

    it { should belong_to(:project) }
    it { should belong_to(:grader) }
  end

  describe "validations" do
    context "grading scale" do
      before do
        @grade = FactoryBot.build(:grade, project: @assignment_project, grader: @mentor,
            grade: "A", assignment: @assignment)
      end

      context "letter grading scale" do
        it "validates grading scale" do
          expect(@grade).to be_valid
          @grade.grade = "199"
          expect(@grade).to be_invalid
          @grade.grade = "G"
          expect(@grade).to be_invalid
        end
      end

      context "percent grading scale" do
        before do
          assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :percent)
          assignment_project = FactoryBot.create(:project, assignment: assignment,
            author: FactoryBot.create(:user))
          @grade = FactoryBot.build(:grade, project: assignment_project, grader: @mentor,
            grade: "98", assignment: assignment)
        end

        it "validates grading scale" do
          expect(@grade).to be_valid
          @grade.grade = "123"
          expect(@grade).to be_invalid
          @grade.grade = "-1"
          expect(@grade).to be_invalid
          @grade.grade = "A"
          expect(@grade).to be_invalid
        end
      end

      context "no grading scale" do
        before do
          assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :no_scale)
          assignment_project = FactoryBot.create(:project, assignment: assignment,
            author: FactoryBot.create(:user))
          @grade = FactoryBot.build(:grade, project: assignment_project, grader: @mentor,
            grade: "98", assignment: assignment)
        end

        it "invalidates all grades" do
          expect(@grade).to be_invalid
          @grade.grade = "A"
          expect(@grade).to be_invalid
          @grade.grade = "19"
          expect(@grade).to be_invalid
        end
      end

      context "custom grading scale" do
        before do
          assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :custom)
          assignment_project = FactoryBot.create(:project, assignment: assignment,
            author: FactoryBot.create(:user))
          @grade = FactoryBot.build(:grade, project: assignment_project, grader: @mentor,
            grade: "98", assignment: assignment)
        end

        it "validates all grades" do
          expect(@grade).to be_valid
          @grade.grade = "123"
          expect(@grade).to be_valid
          @grade.grade = "-1"
          expect(@grade).to be_valid
          @grade.grade = "A-"
          expect(@grade).to be_valid
        end
      end
    end

    context "assignment and project" do
      before do
        @grade = FactoryBot.build(:grade, project: @assignment_project, grader: @mentor,
            grade: "A", assignment: @assignment)
      end

      it "validates assignment and project relations" do
        expect(@grade).to be_valid
        @assignment_project.assignment = FactoryBot.create(:assignment, group: @group)
        @assignment_project.save
        expect(@grade).to be_invalid
      end
    end
  end
end
