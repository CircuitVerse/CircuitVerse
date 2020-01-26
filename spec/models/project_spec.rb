# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  before do
    @user = FactoryBot.create(:user)
    group = FactoryBot.create(:group, mentor: @user)
    @assignment = FactoryBot.create(:assignment, group: group)
  end

  describe "associations" do
    it { should belong_to(:author) }
    it { should belong_to(:assignment).optional }
    it { should belong_to(:forked_project).optional }
    it { should have_many(:forks) }
    it { should have_many(:stars) }
    it { should have_many(:collaborations) }
    it { should have_many(:collaborators) }
    it { should have_one(:featured_circuit) }
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
          expect {
            @project.send_mail
          }.to have_enqueued_job.on_queue("mailers")
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
          expect {
            @project.send_mail
          }.to_not have_enqueued_job.on_queue("mailers")
        end
      end
    end

    describe "#increase_views" do
      before do
        @project = FactoryBot.build(:project, assignment: @assignment, author: @user)
        @viewer = FactoryBot.create(:user)
      end

      it "increases the number of views" do
        expect {
          @project.increase_views(@viewer)
        }.to change { @project.view }.by(1)
      end
    end

    describe "#check_and_remove_featured" do
      before do
        @project = FactoryBot.create(:project, author: @user, project_access_type: "Public")
        FactoryBot.create(:featured_circuit, project: @project)
      end

      it "should remove featured project if project access is not public" do
        expect {
          @project.project_access_type = "Private"
          @project.save
        }.to change { FeaturedCircuit.count }.by(-1)
      end
    end
  end
end
