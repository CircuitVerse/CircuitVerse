# frozen_string_literal: true

class CommentThreadsController < ApplicationController
  skip_after_action :verify_authorized

  before_action :authenticate_user!
  before_action :load_thread

  # PATCH /comment_threads/:id/close
  def close
    return head :forbidden unless @thread.can_be_edited_by?(current_user)

    if @thread.close(current_user)
      redirect_back_or_to(root_path, notice: t("comments.thread_closed"))
    else
      redirect_back_or_to(root_path, alert: t("comments.thread_already_closed"))
    end
  end

  # PATCH /comment_threads/:id/reopen
  def reopen
    return head :forbidden unless @thread.can_be_edited_by?(current_user)

    if @thread.reopen
      redirect_back_or_to(root_path, notice: t("comments.thread_reopened"))
    else
      redirect_back_or_to(root_path, alert: t("comments.thread_already_open"))
    end
  end

  private

    def load_thread
      @thread = CommentThread.find(params.expect(:id))
    end
end
