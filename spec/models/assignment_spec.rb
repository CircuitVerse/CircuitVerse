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

    describe "#testbench_data=" do
      let(:suite) do
        { "type" => "comb",
          "groups" => [{ "label" => "Case 1", "n" => 1,
                         "inputs" => [{ "label" => "a", "bitWidth" => 1, "values" => ["1"] }],
                         "outputs" => [{ "label" => "out", "bitWidth" => 1, "values" => ["1"] }] }] }
      end

      it "builds a testbench from serialised JSON" do
        @assignment.testbench_data = suite.to_json
        expect(@assignment).to be_valid
        expect(@assignment.testbench.data).to eq(suite)
      end

      it "leaves the testbench untouched when the field is absent" do
        @assignment.testbench_data = suite.to_json
        @assignment.save!
        @assignment.testbench_data = nil
        expect(@assignment.testbench).to be_present
      end

      it "removes the testbench when serialised as blank" do
        @assignment.testbench_data = suite.to_json
        @assignment.save!
        @assignment.testbench_data = ""
        @assignment.save!
        expect(@assignment.reload.testbench).to be_nil
      end

      it "rejects malformed or invalid testbench data" do
        ["{not json", { "groups" => [nil] }.to_json].each do |input|
          @assignment.testbench_data = input
          expect(@assignment).not_to be_valid
          expect(@assignment.errors[:testbench]).to include("must be valid JSON with a groups array")
        end
      end
    end
  end
end
