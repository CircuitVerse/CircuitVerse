# frozen_string_literal: true

require "rails_helper"

describe CommentsController, type: :request do
  let(:author) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project, author: author, project_access_type: "Public") }
  let(:thread) { project.comment_thread }

  describe "#create" do
    context "when not authenticated" do
      it "redirects to login" do
        post comment_thread_comments_path(thread), params: { comment: { body: "hi" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in author }

      it "creates a comment and renders it" do
        expect do
          post comment_thread_comments_path(thread), params: { comment: { body: "hello" } }
        end.to change(Comment, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.body).to include("hello")
      end

      it "rejects blank bodies" do
        post comment_thread_comments_path(thread), params: { comment: { body: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "rejects comments on closed threads" do
        thread.close(FactoryBot.create(:user, :admin))
        post comment_thread_comments_path(thread), params: { comment: { body: "hello" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#update" do
    let!(:comment) { FactoryBot.create(:comment, thread: thread, creator: author) }

    it "forbids other users" do
      sign_in FactoryBot.create(:user)
      patch comment_path(comment), params: { comment: { body: "edited" } }
      expect(response).to have_http_status(:forbidden)
    end

    it "updates own comments" do
      sign_in author
      patch comment_path(comment), params: { comment: { body: "edited" } }
      expect(response).to have_http_status(:ok)
      expect(comment.reload.body).to eq("edited")
    end
  end

  describe "#destroy" do
    let!(:comment) { FactoryBot.create(:comment, thread: thread, creator: author) }

    it "soft deletes own comments and renders the placeholder" do
      sign_in author
      delete comment_path(comment)
      expect(response).to have_http_status(:ok)
      expect(comment.reload.is_deleted?).to be true
      expect(response.body).to include("Comment deleted by")
    end

    it "forbids other users" do
      sign_in FactoryBot.create(:user)
      delete comment_path(comment)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
