# frozen_string_literal: true

require "rails_helper"

describe AssignmentPolicy do
  subject { described_class.new(user, assignment) }

  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  context "user is mentor" do
    let(:user) { @mentor }
    let(:assignment) { FactoryBot.create(:assignment, group: @group) }

    it { is_expected.to permit(:admin_access) }

    context "assignment is graded and past deadline" do
      let(:assignment) do
        FactoryBot.create(:assignment,
                          group: @group, grading_scale: :letter, deadline: Time.zone.now - 1.day)
      end

      it { is_expected.to permit(:can_be_graded) }
    end

    context "assignment is ungraded" do
      let(:assignment) do
        FactoryBot.create(:assignment, group: @group,
                                       deadline: Time.zone.now - 1.day, grading_scale: :no_scale)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end

    context "assignment is graded but deadline has not passed" do
      let(:assignment) do
        FactoryBot.create(:assignment, group: @group,
                                       deadline: Time.zone.now + 1.day, grading_scale: :letter)
      end

      it { is_expected.not_to permit(:can_be_graded) }
    end
  end

  context "user is a group member" do
    let(:user) { @member }

    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @member)
    end

    context "assignment is graded and past deadline" do
      let(:assignment) do
        FactoryBot.create(:assignment,
                          group: @group, grading_scale: :letter, deadline: Time.zone.now - 1.day)
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
