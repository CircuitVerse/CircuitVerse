# frozen_string_literal: true

require "rails_helper"

RSpec.describe Assignment, type: :model do
  include ActiveJob::TestHelper

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

    it "sends new assignment mail with scalar IDs" do
      expect do
        @assignment.send_new_assignment_mail
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with("AssignmentMailer", "new_assignment_email", "deliver_now",
              { args: [@group.group_members.first.user_id, @assignment.id] })
        .on_queue("mailers")
    end

    it "sends assignment update mail with scalar IDs" do
      expect do
        @assignment.send_update_mail
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with("AssignmentMailer", "update_assignment_email", "deliver_now",
              { args: [@group.group_members.first.user_id, @assignment.id] })
        .on_queue("mailers")
    end

    it "executes enqueued mailer job safely even if assignment is deleted before processing" do
      @assignment.send_new_assignment_mail
      @assignment.destroy!

      expect { perform_enqueued_jobs }.not_to raise_error
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
  end
end
