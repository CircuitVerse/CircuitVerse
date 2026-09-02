# frozen_string_literal: true

require "rails_helper"

describe CommentPolicy do
  subject { described_class.new(user, comment) }

  let(:project_author) { FactoryBot.create(:user) }
  let(:commenter)      { FactoryBot.create(:user) }
  let(:project)        { FactoryBot.create(:project, :public, author: project_author) }
  let(:comment_thread) { FactoryBot.create(:comment_thread, commentable: project) }
  let(:comment) do
    FactoryBot.create(:comment, comment_thread: comment_thread, user: commenter)
  end

  context "when the user wrote the comment" do
    let(:user) { commenter }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:destroy) }
    it { is_expected.not_to permit(:vote) }
  end

  context "when the user is another signed in user" do
    let(:user) { FactoryBot.create(:user) }

    it { is_expected.to permit(:show) }
    it { is_expected.to permit(:vote) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:destroy) }
  end

  context "when the user is a site admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }

    # moderator_permissions is :d, so moderators delete but do not edit.
    it { is_expected.to permit(:destroy) }
    it { is_expected.not_to permit(:update) }
  end

  context "when the user is anonymous" do
    let(:user) { nil }

    it { is_expected.to permit(:show) }
    it { is_expected.not_to permit(:vote) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:destroy) }
  end

  context "when the comment was deleted by its author" do
    let(:user) { commenter }
    let(:comment) do
      FactoryBot.create(:comment, :deleted, comment_thread: comment_thread,
                                            user: commenter, editor: commenter)
    end

    it { is_expected.not_to permit(:update) }
    it { is_expected.to permit(:restore) }
    it { is_expected.not_to permit(:vote) }
  end

  context "when the comment was deleted by a moderator" do
    let(:user) { commenter }
    let(:comment) do
      FactoryBot.create(:comment, :deleted, comment_thread: comment_thread,
                                            user: commenter,
                                            editor: FactoryBot.create(:user, admin: true))
    end

    it "does not let the author undelete it" do
      expect(subject).not_to permit(:restore)
    end
  end

  context "when the thread is closed" do
    before { comment_thread.close!(FactoryBot.create(:user, admin: true)) }

    context "for the comment author" do
      let(:user) { commenter }

      it { is_expected.to permit(:show) }
      it { is_expected.not_to permit(:update) }
      it { is_expected.not_to permit(:destroy) }
    end

    # can_be_deleted_by? returns for moderators before the closed-thread check.
    context "for a site admin" do
      let(:user) { FactoryBot.create(:user, admin: true) }

      it { is_expected.to permit(:destroy) }
    end
  end

  context "when the project is private" do
    let(:project) { FactoryBot.create(:project, author: project_author) }
    let(:user)    { FactoryBot.create(:user) }

    it { is_expected.not_to permit(:show) }
    it { is_expected.not_to permit(:vote) }
  end
end
