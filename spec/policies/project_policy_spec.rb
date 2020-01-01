# frozen_string_literal: true

require "rails_helper"

describe ProjectPolicy do
  subject { ProjectPolicy.new(user, project) }

  def permit_all
    should permit(:user_access)
    should permit(:edit_access)
    should permit(:view_access)
    should permit(:direct_view_access)
    should permit(:create_fork)
    should permit(:author_access)
  end

  before do
    @author = FactoryBot.create(:user)
  end

  context "project is public" do
    let(:project) { FactoryBot.create(:project, author: @author, project_access_type: "Public") }

    context "for author" do
      let(:user) { @author }
      it "permits all" do
        permit_all
      end

      it { should_not permit(:can_feature) }
    end

    context "for a visitor" do
      let(:user) { FactoryBot.create(:user) }

      it { should permit(:view_access) }
      it { should permit(:direct_view_access) }
      it { should permit(:create_fork) }
      it { should permit(:embed) }
      it { should_not permit(:author_access) }
      it { should_not permit(:user_access) }

      it "should raise error for edit access" do
        check_auth_exception(subject, :edit_access)
      end
    end

    context "for admin" do
      let(:user) { FactoryBot.create(:user, admin: true) }

      it { should permit(:can_feature) }
    end
  end

  context "project is assignment" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, author: @author, assignment: @assignment) }

    before do
      mentor = FactoryBot.create(:user)
      group = FactoryBot.create(:group, mentor: mentor)
      @assignment = FactoryBot.create(:assignment, group: group)
    end

    it { should_not permit(:create_fork) }
  end

  context "project is assignment submission" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, author: user) }

    before do
      project.project_submission = true
    end

    it { should permit(:view_access) }
    it "should raise error for edit access" do
      check_auth_exception(subject, :edit_access)
    end
  end

  context "project is private" do
    let(:project) { FactoryBot.create(:project, author: @author, project_access_type: "Private") }

    context "for author" do
      let(:user) { @author }
      it "permits all" do
        permit_all
      end
    end

    context "for admin" do
      let(:user) { FactoryBot.create(:user, admin: true) }

      it { should_not permit(:can_feature) }
    end

    context "for a visitor" do
      let(:user) { FactoryBot.create(:user) }

      it "should raise error" do
        check_auth_exception(subject, :edit_access)
        check_auth_exception(subject, :view_access)
        check_auth_exception(subject, :direct_view_access)
        check_auth_exception(subject, :embed)
      end
    end
  end
end
