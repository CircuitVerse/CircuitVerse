# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assignment, type: :model do
  before do
    @primary_mentor = create(:user)
    @group = create(:group, primary_mentor: @primary_mentor)
  end

  describe "associations" do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:projects) }
  end

  describe "callbacks" do
    it "calls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_new_assignment_mail)
      expect_any_instance_of(described_class).to receive(:send_update_mail)
      expect_any_instance_of(described_class).to receive(:set_deadline_job).twice
      assignment = create(:assignment, group: @group)
      assignment.status = "open"
      assignment.save
    end
  end

  context "public methods" do
    before do
      user = create(:user)
      create(:group_member, group: @group, user: user)
      @assignment = create(:assignment, group: @group, status: "open")
    end

    it "sends new assignment mail" do
      expect do
        @assignment.send_new_assignment_mail
      end.to have_enqueued_job.on_queue("mailers")
    end

    it "sends assignment update mail" do
      expect do
        @assignment.send_update_mail
      end.to have_enqueued_job.on_queue("mailers")
    end

    it "sets deadline submission job" do
      expect do
        @assignment.set_deadline_job
      end.to have_enqueued_job(AssignmentDeadlineSubmissionJob).on_queue("default")
    end

    describe "#project_order" do
      before do
        @projects = []

        3.times do
          @projects << create(:project, assignment: @assignment,
                                        author: create(:user))
        end
      end

      it "gives sorted assignment projects" do
        expect(@assignment.project_order.map { |p| p.author.name })
          .to eq(@projects.map { |p| p.author.name }.sort)
      end
    end
  end
end
