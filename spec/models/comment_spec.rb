# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:author)  { create(:user) }
  let(:project) { create(:project, author: author) }
  let(:thread)  { create(:comment_thread, commentable: project) }

  describe "associations" do
    it "belongs to a thread and a user" do
      comment = create(:comment, comment_thread: thread, user: author)

      expect(comment.comment_thread).to eq(thread)
      expect(comment.user).to eq(author)
    end

    it "exposes replies through the parent association" do
      parent = create(:comment, comment_thread: thread, user: author)
      reply  = create(:comment, comment_thread: thread, user: author, parent: parent)

      expect(parent.replies).to contain_exactly(reply)
      expect(reply.parent).to eq(parent)
    end

    it "destroys replies when the parent is destroyed" do
      parent = create(:comment, comment_thread: thread, user: author)
      create(:comment, comment_thread: thread, user: author, parent: parent)

      expect { parent.destroy }.to change(described_class, :count).by(-2)
    end
  end

  describe "validations" do
    it "requires a body" do
      comment = build(:comment, comment_thread: thread, user: author, body: nil)

      expect(comment).not_to be_valid
      expect(comment.errors[:body]).to be_present
    end

    it "rejects a body longer than the maximum length" do
      comment = build(:comment, comment_thread: thread, user: author,
                                body: "a" * (described_class::BODY_MAX_LENGTH + 1))

      expect(comment).not_to be_valid
    end

    it "rejects a reply whose parent lives in a different thread" do
      other_thread = create(:comment_thread, commentable: create(:project, author: author))
      other_parent = create(:comment, comment_thread: other_thread, user: author)
      reply        = build(:comment, comment_thread: thread, user: author, parent: other_parent)

      expect(reply).not_to be_valid
      expect(reply.errors[:parent]).to be_present
    end

    it "rejects a comment that is its own parent" do
      comment = create(:comment, comment_thread: thread, user: author)
      comment.parent = comment

      expect(comment).not_to be_valid
    end

    it "rejects a cycle between two comments" do
      first  = create(:comment, comment_thread: thread, user: author)
      second = create(:comment, comment_thread: thread, user: author, parent: first)
      first.parent = second

      expect(first).not_to be_valid
    end
  end

  describe "scopes" do
    let!(:visible) { create(:comment, comment_thread: thread, user: author) }
    let!(:removed) { create(:comment, :deleted, comment_thread: thread, user: author) }

    it "excludes soft deleted comments from .kept" do
      expect(described_class.kept).to contain_exactly(visible)
    end

    it "returns only top level comments from .roots" do
      create(:comment, comment_thread: thread, user: author, parent: visible)

      expect(described_class.roots).to contain_exactly(visible, removed)
    end
  end

  describe "soft deletion" do
    let(:comment) { create(:comment, comment_thread: thread, user: author) }

    it "marks the comment as deleted without removing the row" do
      comment # create it before measuring the count

      expect { comment.soft_delete! }.not_to change(described_class, :count)
      expect(comment).to be_deleted
    end

    it "restores a soft deleted comment" do
      comment.soft_delete!
      comment.restore!

      expect(comment).not_to be_deleted
    end
  end

  describe "#edited?" do
    it "is false until an editor is recorded" do
      comment = create(:comment, comment_thread: thread, user: author)

      expect(comment).not_to be_edited
      comment.update!(body: "changed", editor: author)
      expect(comment).to be_edited
    end
  end
end
