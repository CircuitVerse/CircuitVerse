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
      project = FactoryBot.create(:project, assignment: @assignment, author: @user)
      expect(project).to be_valid
      project.project_access_type = "Public"
      expect(project).to be_invalid
    end

    it "doesn't allow profanities in description" do
      project = FactoryBot.create(:project, assignment: @assignment, author: @user)
      expect(project).to be_valid
      project.description = "Ass"
      expect(project).to be_invalid
    end
  end

  describe "template flag" do
    it "defaults to a private non-template" do
      project = FactoryBot.create(:project, author: @user)
      expect(project.is_template).to be(false)
      expect(project).to be_template_private
    end

    it "allows a standalone project to be marked as a template" do
      project = FactoryBot.build(:project, author: @user, is_template: true, template_visibility: :public)
      expect(project).to be_valid
    end

    it "does not allow an assignment project to be marked as a template" do
      project = FactoryBot.build(:project, author: @user, assignment: @assignment, is_template: true)
      expect(project).to be_invalid
      expect(project.errors[:base]).to include("Assignment projects cannot be saved as templates")
    end

    it "accepts a runnable test suite on a template" do
      project = FactoryBot.build(:project, author: @user, is_template: true,
                                           template_testbench: FactoryBot.build(:testbench).data)
      expect(project).to be_valid
    end

    it "rejects a template test suite that is not runnable" do
      project = FactoryBot.build(:project, author: @user, is_template: true,
                                           template_testbench: { "type" => "verilog" })
      expect(project).to be_invalid
      expect(project.errors[:template_testbench]).to be_present
    end
  end

  describe "#fork" do
    it "does not copy template status to the fork" do
      template = FactoryBot.create(:project, :public, author: @user, is_template: true, template_visibility: :public)
      forked = template.fork(FactoryBot.create(:user))
      expect(forked.is_template).to be(false)
      expect(forked).to be_template_private
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
        @project = FactoryBot.create(:project, assignment: @assignment, author: @user)
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
