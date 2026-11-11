# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project, project_access_type: "Public") }
  let(:thread) { project.comment_thread }
  let(:comment) { FactoryBot.create(:comment, thread: thread, creator: user) }

  describe "validations" do
    it "requires a body" do
      comment.body = ""
      expect(comment).not_to be_valid
    end

    it "rejects duplicate bodies from the same creator in a thread" do
      existing = comment
      duplicate = FactoryBot.build(:comment, thread: thread, creator: user, body: existing.body)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:body]).to include("is a duplicate of another comment.")
    end
  end

  describe "soft deletion" do
    it "deletes" do
      expect(comment.is_deleted?).to be false
      expect(comment.delete_by(user)).to be_truthy
      expect(comment.is_deleted?).to be true
      expect(comment.delete_by(user)).to be false
    end

    it "undeletes" do
      comment.delete_by(user)
      expect(comment.undelete_by(user)).to be_truthy
      expect(comment.is_deleted?).to be false
      expect(comment.undelete_by(user)).to be false
    end

    it "shows a placeholder body when deleted" do
      comment.delete_by(user)
      expect(comment.body).to eq("Comment deleted by #{user.name}.")
    end
  end

  describe "permissions" do
    it "lets creators create on open readable threads" do
      draft = FactoryBot.build(:comment, thread: thread, creator: user)
      expect(draft.can_be_created_by?(user)).to be true
      expect(draft.can_be_created_by?(nil)).to be false
    end

    it "blocks creation on closed threads" do
      thread.close(FactoryBot.create(:user, :admin))
      draft = FactoryBot.build(:comment, thread: thread, creator: user)
      expect(draft.can_be_created_by?(user)).to be false
    end

    it "lets creators edit and delete their comments" do
      expect(comment.can_be_edited_by?(user)).to be true
      expect(comment.can_be_deleted_by?(user)).to be true
      other = FactoryBot.create(:user)
      expect(comment.can_be_edited_by?(other)).to be false
      expect(comment.can_be_deleted_by?(other)).to be false
    end

    it "lets admins edit and delete any comment" do
      admin = FactoryBot.create(:user, :admin)
      expect(comment.can_be_edited_by?(admin)).to be true
      expect(comment.can_be_deleted_by?(admin)).to be true
    end

    it "blocks edits and deletes on closed threads" do
      thread.close(FactoryBot.create(:user, :admin))
      expect(comment.can_be_edited_by?(user)).to be false
      expect(comment.can_be_deleted_by?(user)).to be false
    end
  end

  describe "voting" do
    it "tracks upvotes" do
      voter = FactoryBot.create(:user)
      expect(comment.can_be_voted_on_by?(voter)).to be true
      expect(comment.can_be_voted_on_by?(user)).to be false
      comment.upvote_from(voter)
      expect(comment.reload.cached_votes_up).to eq(1)
      expect(comment.get_vote_by(voter)).not_to be_nil
    end

    it "tracks downvotes and unvotes" do
      voter = FactoryBot.create(:user)
      comment.upvote_from(voter)
      comment.downvote_from(voter)
      expect(comment.reload.cached_votes_down).to eq(1)
      comment.unvote(voter: voter)
      expect(comment.reload.cached_votes_up).to eq(0)
    end
  end
end
