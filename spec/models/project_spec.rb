# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project do
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
  end
end
