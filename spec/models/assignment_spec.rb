# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assignment, type: :model do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
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
      assignment = FactoryBot.create(:assignment, group: @group)
      assignment.status = "open"
      assignment.save
    end
  end

  context "public methods" do
    before do
      user = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: user)
      @assignment = FactoryBot.create(:assignment, group: @group, status: "open")
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
          @projects << FactoryBot.create(:project, assignment: @assignment,
                                                   author: FactoryBot.create(:user))
        end
      end

      it "gives sorted assignment projects" do
        expect(@assignment.project_order.map { |p| p.author.name })
          .to eq(@projects.map { |p| p.author.name }.sort)
      end
    end

    describe "#freeze_submissions" do
      before do
        @student = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, assignment: @assignment, author: @student,
                                               project_submission: false)
      end

      it "forks projects into frozen submissions and unlinks original projects" do
        @assignment.freeze_submissions
        @project.reload
        expect(@project.assignment_id).to be_nil
        expect(@project.project_submission).to be(false)

        submission = @assignment.projects.find_by(author: @student)
        expect(submission).to be_present
        expect(submission.project_submission).to be(true)
        expect(submission.forked_project_id).to eq(@project.id)
      end

      it "skips projects that are already submitted" do
        @assignment.freeze_submissions
        expect do
          @assignment.freeze_submissions
        end.not_to change(Project, :count)
      end
    end
  end
end
