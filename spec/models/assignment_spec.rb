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
  end

  describe "#lms_score_for" do
    context "with the percent scale" do
      let(:assignment) { described_class.new(grading_scale: :percent) }

      it "maps 0-100 to 0.0-1.0" do
        expect(assignment.lms_score_for("85")).to eq(0.85)
        expect(assignment.lms_score_for("100")).to eq(1.0)
        expect(assignment.lms_score_for("0")).to eq(0.0)
      end

      it "clamps out-of-range values" do
        expect(assignment.lms_score_for("150")).to eq(1.0)
        expect(assignment.lms_score_for("-5")).to eq(0.0)
      end

      it "returns nil for non-numeric or blank grades" do
        expect(assignment.lms_score_for("A")).to be_nil
        expect(assignment.lms_score_for("")).to be_nil
        expect(assignment.lms_score_for(nil)).to be_nil
      end
    end

    context "with the letter scale" do
      let(:assignment) { described_class.new(grading_scale: :letter) }

      it "maps each letter to a score" do
        expect(assignment.lms_score_for("A")).to eq(1.0)
        expect(assignment.lms_score_for("B")).to eq(0.8)
        expect(assignment.lms_score_for("F")).to eq(0.0)
      end

      it "ignores case and surrounding whitespace" do
        expect(assignment.lms_score_for(" a ")).to eq(1.0)
      end

      it "returns nil for unknown or blank grades" do
        expect(assignment.lms_score_for("Z")).to be_nil
        expect(assignment.lms_score_for("")).to be_nil
      end
    end

    context "with the custom scale" do
      it "returns nil" do
        assignment = described_class.new(grading_scale: :custom)
        expect(assignment.lms_score_for("Excellent work")).to be_nil
      end
    end

    context "with no scale" do
      it "returns nil" do
        assignment = described_class.new(grading_scale: :no_scale)
        expect(assignment.lms_score_for("A")).to be_nil
      end
    end
  end
end
