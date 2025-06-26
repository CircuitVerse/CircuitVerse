# frozen_string_literal: true

require "rails_helper"

describe ProjectPolicy do
  subject { described_class.new(user, project) }

  def permit_all
    expect(subject).to permit(:user_access)
    expect(subject).to permit(:edit_access)
    expect(subject).to permit(:view_access)
    expect(subject).to permit(:direct_view_access)
    expect(subject).to permit(:create_fork)
    expect(subject).to permit(:author_access)
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

      it { is_expected.not_to permit(:can_feature) }
    end

    context "for a visitor" do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to permit(:view_access) }
      it { is_expected.to permit(:direct_view_access) }
      it { is_expected.to permit(:create_fork) }
      it { is_expected.to permit(:embed) }
      it { is_expected.not_to permit(:author_access) }
      it { is_expected.not_to permit(:user_access) }

      it "raises error for edit access" do
        check_auth_exception(subject, :edit_access)
      end
    end

    context "for admin" do
      let(:user) { FactoryBot.create(:user, admin: true) }

      it { is_expected.to permit(:can_feature) }
    end
  end

  context "project is assignment" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, author: @author, assignment: @assignment) }

    before do
      primary_mentor = FactoryBot.create(:user)
      group = FactoryBot.create(:group, primary_mentor: primary_mentor)
      @assignment = FactoryBot.create(:assignment, group: group)
    end

    it { is_expected.not_to permit(:create_fork) }
  end

  context "project is assignment submission" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, author: user) }

    before do
      project.project_submission = true
    end

    it { is_expected.to permit(:view_access) }

    it "raises error for edit access" do
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

      it { is_expected.not_to permit(:can_feature) }
    end

    context "for a visitor" do
      let(:user) { FactoryBot.create(:user) }

      it "raises error" do
        check_auth_exception(subject, :edit_access)
        check_auth_exception(subject, :view_access)
        check_auth_exception(subject, :direct_view_access)
        check_auth_exception(subject, :embed)
      end
    end
  end
end
