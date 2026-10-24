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

    describe "#close!" do
      let(:member) { FactoryBot.create(:user) }
      let!(:project) { FactoryBot.create(:project, assignment: @assignment, author: member) }

      it "freezes submissions and closes the assignment" do
        FactoryBot.create(:project_datum, project: project, data: "original")
        @assignment.close!
        expect(@assignment.reload.status).to eq("closed")

        submission = @assignment.projects.find_by(author: member)
        expect(submission.project_submission).to be(true)
        expect(submission.forked_project_id).to eq(project.id)
        expect(project.reload.assignment_id).to be_nil

        project.project_datum.update!(data: "edited")
        expect(submission.project_datum.reload.data).to eq("original")
      end

      it "does nothing when closed a second time" do
        @assignment.close!
        deadline = @assignment.reload.deadline

        expect(@assignment.close!).to be(false)
        expect(@assignment.projects.where(project_submission: true).count).to eq(1)
        expect(@assignment.reload.deadline).to eq(deadline)
      end

      it "rolls back if freezing a later project fails" do
        other_project = FactoryBot.create(:project, assignment: @assignment, author: FactoryBot.create(:user))
        forks = 0
        allow_any_instance_of(Project).to receive(:fork).and_wrap_original do |original, *args|
          forks += 1
          raise ActiveRecord::RecordInvalid if forks == 2

          original.call(*args)
        end

        expect { @assignment.close! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(@assignment.reload.status).to eq("open")
        expect(@assignment.projects.where(project_submission: true)).to be_empty
        expect([project.reload, other_project.reload].map(&:assignment_id)).to all(eq(@assignment.id))
      end
    end
  end
end
