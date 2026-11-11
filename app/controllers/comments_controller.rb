# frozen_string_literal: true

# HTML comment actions for the project page thread. Authorization mirrors the
# JSON API and lives in Comment#can_be_*_by? instead of a Pundit policy.
class CommentsController < ApplicationController
  skip_after_action :verify_authorized

  before_action :authenticate_user!

  # POST /comment_threads/:comment_thread_id/comments
  def create
    thread = CommentThread.find(params.expect(:comment_thread_id))
    comment = thread.comments.build(body: params.dig(:comment, :body), creator: current_user)

    return head :forbidden unless comment.can_be_created_by?(current_user)

    if comment.save
      thread.subscribe(current_user)
      render partial: "comments/comment", locals: { comment: comment }, status: :created
    else
      render partial: "comments/errors", locals: { comment: comment }, status: :unprocessable_content
    end
  end

  # PATCH /comments/:id
  def update
    comment = Comment.find(params.expect(:id))
    comment.editor = current_user
    comment.body = params.dig(:comment, :body)

    return head :forbidden unless comment.can_be_edited_by?(current_user)

    if comment.save
      render partial: "comments/comment", locals: { comment: comment }
    else
      render partial: "comments/errors", locals: { comment: comment }, status: :unprocessable_content
    end
  end

  # DELETE /comments/:id
  def destroy
    comment = Comment.find(params.expect(:id))

    return head :forbidden unless comment.can_be_deleted_by?(current_user)

    if comment.delete_by(current_user)
      render partial: "comments/comment", locals: { comment: comment }
    else
      head :conflict
    end
  end
end
