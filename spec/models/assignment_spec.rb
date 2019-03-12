require 'rails_helper'

RSpec.describe Assignment, type: :model do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  describe "associations" do
    it { should belong_to(:group) }
    it { should have_many(:projects) }
  end

  describe "callbacks", :focus do
    it "should call respective callbacks" do
      expect_any_instance_of(Assignment).to receive(:send_new_assignment_mail)
      expect_any_instance_of(Assignment).to receive(:send_update_mail)
      expect_any_instance_of(Assignment).to receive(:set_deadline_job).twice
      assignment = FactoryBot.create(:assignment, group: @group)
      assignment.status = 'open'
      assignment.save
    end
  end

  context "public methods" do
    before do
      user = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: user)
      @assignment = FactoryBot.create(:assignment, group: @group, status: 'open')
    end

    it "sends new assignment mail" do
      expect {
        @assignment.send_new_assignment_mail
      }.to have_enqueued_job.on_queue('mailers')
    end

    it "sends assignment update mail" do
      expect {
        @assignment.send_update_mail
      }.to have_enqueued_job.on_queue('mailers')
    end

    it "sets deadline submission job" do
      expect {
        @assignment.set_deadline_job
      }.to have_enqueued_job(AssignmentDeadlineSubmissionJob).on_queue('default')
    end
  end
end
