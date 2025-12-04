# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  before do
    @user = FactoryBot.create(:user)
    group = FactoryBot.create(:group, primary_mentor: @user)
    @assignment = FactoryBot.create(:assignment, group: group)
  end

  describe "associations" do
    it { is_expected.to belong_to(:author) }
    it { is_expected.to belong_to(:assignment).optional }
    it { is_expected.to belong_to(:forked_project).optional }
    it { is_expected.to have_many(:forks) }
    it { is_expected.to have_many(:stars) }
    it { is_expected.to have_many(:collaborations) }
    it { is_expected.to have_many(:collaborators) }
    it { is_expected.to have_one(:featured_circuit) }
    it { is_expected.to have_many(:noticed_notifications) }
    it { is_expected.to have_one(:contest_winner) }
    it { is_expected.to have_many(:submissions) }
  end

  describe "validity" do
    it "doesn't validate with public access type" do
      project = FactoryBot.build(:project, assignment: @assignment, author: @user)
      expect(project).to be_valid
      project.project_access_type = "Public"
      expect(project).to be_invalid
    end

    it "doesn't allow profanities in description" do
      project = FactoryBot.build(:project, assignment: @assignment, author: @user)
      expect(project).to be_valid
      project.description = "Ass"
      expect(project).to be_invalid
    end
  end

  describe "public methods" do
    context "project submission is false" do
      before do
        @project = FactoryBot.create(
          :project,
          assignment: @assignment,
          author: @user,
          project_submission: false
        )
      end

      describe "#send_mail" do
        it "sends new project mail" do
          expect do
            @project.send_mail
          end.to have_enqueued_job.on_queue("mailers")
        end
      end
    end

    context "project submission is true" do
      before do
        @project = FactoryBot.create(
          :project,
          assignment: @assignment,
          author: @user,
          project_submission: true
        )
      end

      describe "#send_mail" do
        it "doesn't send new project mail" do
          expect do
            @project.send_mail
          end.not_to have_enqueued_job.on_queue("mailers")
        end
      end
    end

    describe "#increase_views" do
      before do
        @project = FactoryBot.build(:project, assignment: @assignment, author: @user)
        @viewer = FactoryBot.create(:user)
      end

      it "increases the number of views" do
        expect do
          @project.increase_views(@viewer)
        end.to change { @project.view }.by(1)
      end
    end

    describe "#check_and_remove_featured" do
      before do
        @project = FactoryBot.create(:project, author: @user, project_access_type: "Public")
        FactoryBot.create(:featured_circuit, project: @project)
      end

      it "removes featured project if project access is not public" do
        expect do
          @project.project_access_type = "Private"
          @project.save
        end.to change(FeaturedCircuit, :count).by(-1)
      end
    end

    describe "#sim_version" do
      context "with valid JSON data" do
        it "returns the simulator version from JSON" do
          project = FactoryBot.create(:project, author: @user)
          project.build_project_datum
          project.project_datum.data = '{"simulatorVersion":"v1","name":"test"}'
          project.save!
          expect(project.sim_version).to eq("v1")
        end

        it "returns 'legacy' when simulatorVersion is not present" do
          project = FactoryBot.create(:project, author: @user)
          project.build_project_datum
          project.project_datum.data = '{"name":"test"}'
          project.save!
          expect(project.sim_version).to eq("legacy")
        end
      end

      context "with no project data" do
        it "returns 'legacy' when project_datum is nil" do
          project = FactoryBot.create(:project, author: @user)
          expect(project.sim_version).to eq("legacy")
        end

        it "returns 'legacy' when data is blank" do
          project = FactoryBot.create(:project, author: @user)
          project.build_project_datum
          project.project_datum.data = ""
          project.save!
          expect(project.sim_version).to eq("legacy")
        end
      end

      context "with corrupted JSON data" do
        it "returns 'legacy' when JSON parsing fails" do
          project = FactoryBot.create(:project, author: @user)
          project.build_project_datum
          # Simulate corrupted/truncated JSON
          project.project_datum.data = '{"name":"test","data":{"invalid'
          project.save!
          expect(project.sim_version).to eq("legacy")
        end

        it "logs error when JSON parsing fails" do
          project = FactoryBot.create(:project, author: @user)
          project.build_project_datum
          project.project_datum.data = '{"invalid json'
          project.save!
          
          expect(Rails.logger).to receive(:error).with(/JSON parsing failed/)
          project.sim_version
        end
      end
    end

    describe "#uses_vue_simulator?" do
      it "returns true for v0 simulator" do
        project = FactoryBot.create(:project, author: @user)
        project.build_project_datum
        project.project_datum.data = '{"simulatorVersion":"v0"}'
        project.save!
        expect(project.uses_vue_simulator?).to be true
      end

      it "returns true for v1 simulator" do
        project = FactoryBot.create(:project, author: @user)
        project.build_project_datum
        project.project_datum.data = '{"simulatorVersion":"v1"}'
        project.save!
        expect(project.uses_vue_simulator?).to be true
      end

      it "returns false for legacy simulator" do
        project = FactoryBot.create(:project, author: @user)
        expect(project.uses_vue_simulator?).to be false
      end

      it "returns false when JSON is corrupted" do
        project = FactoryBot.create(:project, author: @user)
        project.build_project_datum
        project.project_datum.data = '{"invalid json'
        project.save!
        expect(project.uses_vue_simulator?).to be false
      end
    end

  end
end
