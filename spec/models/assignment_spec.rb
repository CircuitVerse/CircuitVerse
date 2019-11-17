# frozen_string_literal: true

require "rails_helper"

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
      expect {
        @assignment.send_new_assignment_mail
      }.to have_enqueued_job.on_queue("mailers")
    end

    it "sends assignment update mail" do
      expect {
        @assignment.send_update_mail
      }.to have_enqueued_job.on_queue("mailers")
    end

    it "sets deadline submission job" do
      expect {
        @assignment.set_deadline_job
      }.to have_enqueued_job(AssignmentDeadlineSubmissionJob).on_queue("default")
    end

    describe "#project_order" do
      before do
        @projects = []

        (1..3).each do
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
