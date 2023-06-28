class SimpleDiscussion::NotificationsController < SimpleDiscussion::ApplicationController
  before_action :authenticate_user!
  before_action :set_forum_thread

  def create
    @forum_thread.toggle_subscription(current_user)
    redirect_to simple_discussion.forum_thread_path(@forum_thread)
  end

  def show
    redirect_to simple_discussion.forum_thread_path(@forum_thread)
  end

  private

  def set_forum_thread
    @forum_thread = ForumThread.friendly.find(params[:forum_thread_id])
  end
end
