# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentThread, type: :model do
  let(:author)  { create(:user) }
  let(:project) { create(:project, author: author) }

  describe "associations" do
    it "belongs to a polymorphic commentable" do
      thread = create(:comment_thread, commentable: project)

      expect(thread.commentable).to eq(project)
      expect(project.comment_thread).to eq(thread)
    end

    it "destroys its comments when destroyed" do
      thread = create(:comment_thread, commentable: project)
      create(:comment, comment_thread: thread, user: author)

      expect { thread.destroy }.to change(Comment, :count).by(-1)
    end
  end

  describe "open and closed state" do
    let(:thread) { create(:comment_thread, commentable: project) }

    it "is open by default" do
      expect(thread).not_to be_closed
    end

    it "records who closed it" do
      thread.close!(author)

      expect(thread).to be_closed
      expect(thread.closer).to eq(author)
    end

    it "clears the closer when reopened" do
      thread.close!(author)
      thread.reopen!

      expect(thread).not_to be_closed
      expect(thread.closer).to be_nil
    end
  end
end
