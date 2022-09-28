class SimpleDiscussion::ForumPostsController < SimpleDiscussion::ApplicationController
  before_action :authenticate_user!
  before_action :set_forum_thread
  before_action :set_forum_post, only: [:edit, :update, :destroy]
  before_action :require_mod_or_author_for_post!, only: [:edit, :update, :destroy]
  before_action :require_mod_or_author_for_thread!, only: [:solved, :unsolved]

  def create
    @forum_post = @forum_thread.forum_posts.new(forum_post_params)
    @forum_post.user_id = current_user.id

    if @forum_post.save
      SimpleDiscussion::ForumPostNotificationJob.perform_later(@forum_post)
      redirect_to simple_discussion.forum_thread_path(@forum_thread, anchor: "forum_post_#{@forum_post.id}")
    else
      render template: "simple_discussion/forum_threads/show"
    end
  end

  def edit
  end

  def update
    if @forum_post.update(forum_post_params)
      redirect_to simple_discussion.forum_thread_path(@forum_thread)
    else
      render action: :edit
    end
  end

  def destroy
    @forum_post.destroy!
    redirect_to simple_discussion.forum_thread_path(@forum_thread)
  end

  def solved
    @forum_post = @forum_thread.forum_posts.find(params[:id])

    @forum_thread.forum_posts.update_all(solved: false)
    @forum_post.update_column(:solved, true)
    @forum_thread.update_column(:solved, true)

    redirect_to simple_discussion.forum_thread_path(@forum_thread, anchor: ActionView::RecordIdentifier.dom_id(@forum_post))
  end

  def unsolved
    @forum_post = @forum_thread.forum_posts.find(params[:id])

    @forum_thread.forum_posts.update_all(solved: false)
    @forum_thread.update_column(:solved, false)

    redirect_to simple_discussion.forum_thread_path(@forum_thread, anchor: ActionView::RecordIdentifier.dom_id(@forum_post))
  end

  private

  def set_forum_thread
    @forum_thread = ForumThread.friendly.find(params[:forum_thread_id])
  end

  def set_forum_post
    @forum_post = if is_moderator?
      @forum_thread.forum_posts.find(params[:id])
    else
      current_user.forum_posts.find(params[:id])
    end
  end

  def forum_post_params
    params.require(:forum_post).permit(:body)
  end
end
