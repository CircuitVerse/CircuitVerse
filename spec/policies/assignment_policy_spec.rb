# frozen_string_literal: true

require "rails_helper"

describe AssignmentPolicy do
  subject { described_class.new(user, assignment) }

  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  context "user is primary_mentor" do
    let(:user) { @primary_mentor }
    let(:assignment) { FactoryBot.create(:assignment, group: @group) }

    it { is_expected.to permit(:admin_access) }

    context "assignment is graded and past deadline" do
      let(:assignment) do
        FactoryBot.create(:assignment,
                          group: @group, grading_scale: :letter, deadline: 1.day.ago)
      end

      it { is_expected.to permit(:can_be_graded) }
    end

    context "assignment is ungraded" do
      let(:assignment) do
        FactoryBot.create(:assignment, group: @group,
                                       deadline: 1.day.ago, grading_scale: :no_scale)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end

    context "assignment is graded but deadline has not passed" do
      let(:assignment) do
        FactoryBot.create(:assignment, group: @group,
                                       deadline: 1.day.from_now, grading_scale: :letter)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end
  end

  context "user is a mentor" do
    let(:user) { @mentor }
    let(:assignment) { FactoryBot.create(:assignment, group: @group) }

    before do
      @mentor = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @mentor, mentor: true)
    end

    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.to permit(:mentor_access) }

    context "assignment is graded and past deadline" do
      let(:assignment) do
        FactoryBot.create(:assignment,
                          group: @group, grading_scale: :letter, deadline: 1.day.ago)
      end

      it { is_expected.to permit(:can_be_graded) }
    end

    context "assignment is ungraded" do
      let(:assignment) do
        FactoryBot.create(:assignment, group: @group,
                                       deadline: 1.day.ago, grading_scale: :no_scale)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end

    context "assignment is graded but deadline has not passed" do
      let(:assignment) do
        FactoryBot.create(:assignment, group: @group,
                                       deadline: 1.day.from_now, grading_scale: :letter)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end
  end

  context "user is a group member" do
    let(:user) { @member }
    let(:assignment) { FactoryBot.create(:assignment, group: @group) }

    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @member)
    end

    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:mentor_access) }

    context "assignment is graded and past deadline" do
      let(:assignment) do
        FactoryBot.create(:assignment,
                          group: @group, grading_scale: :letter, deadline: 1.day.ago)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end

    context "assignment is open" do
      let(:assignment) { FactoryBot.create(:assignment, group: @group, status: "open") }

      it { is_expected.not_to permit(:admin_access) }
      it { is_expected.to permit(:edit) }
      it { is_expected.to permit(:start) }

      context "project is already submitted" do
        before do
          FactoryBot.create(:project, author: @member, assignment: assignment)
        end

        it { is_expected.not_to permit(:start) }
      end
    end

    context "assignment is closed" do
      let(:assignment) { FactoryBot.create(:assignment, group: @group, status: "closed") }

      it { is_expected.not_to permit(:start) }
      it { is_expected.not_to permit(:edit) }
    end
  end
end
