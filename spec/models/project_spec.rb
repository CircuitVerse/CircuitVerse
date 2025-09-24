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

    it "prevents duplicate slug-author combinations at database level" do
      # Create first project
      project1 = FactoryBot.create(:project, author: @user, name: "Test Project")
      original_slug = project1.slug

      user2 = FactoryBot.create(:user)

      # Same slug with different author should work (database allows it)
      project2 = FactoryBot.create(:project, author: user2, name: "Test Project")
      project2.update_column(:slug, original_slug)
      expect(project2.reload.slug).to eq(original_slug)

      # Attempting to create another project with same slug and author should fail at DB level
      expect {
        project3 = FactoryBot.create(:project, author: @user, name: "Another Test")
        project3.update_column(:slug, original_slug)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "handles long project names and slugs properly" do
      # Test with very long names that would previously cause index size issues
      long_name = "A" * 1000
      project = FactoryBot.build(:project, author: @user, name: long_name)

      # Should be valid even with long slug
      expect(project).to be_valid

      # Should be able to save without index size errors
      expect { project.save! }.not_to raise_error
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
