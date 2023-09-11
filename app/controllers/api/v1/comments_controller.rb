# frozen_string_literal: true

class Api::V1::CommentsController < Api::V1::BaseController
  before_action :authenticate_user!, except: %i[index]
  before_action :load_index_resource, only: %i[index]
  before_action :load_create_resource, only: %i[create]
  before_action :set_comment_and_thread, except: %i[index create]
  before_action :set_options

  # GET /api/v1/threads/:thread_id/comments
  def index
    @comments = @commontator_thread.comments
    @options[:links] = link_attrs(paginate(@comments), api_v1_thread_comments_url)
    render json: Api::V1::CommentSerializer.new(paginate(@comments), @options)
  end

  # POST /api/v1/threads/:thread_id/comments
  def create
    if @comment.save
      sub = @commontator_thread.config.thread_subscription.to_sym
      @commontator_thread.subscribe(current_user) if %i[a b].include? sub
      Commontator::Subscription.comment_created(@comment)
      render json: Api::V1::CommentSerializer.new(@comment, @options), status: :created
    else
      api_error(status: 422, errors: @comment.errors)
    end
  end

  # PUT/PATCH /api/v1/comments/:id
  def update
    @comment.editor = current_user
    @comment.body = params.dig(:comment, :body)
    security_transgression_unless @comment.can_be_edited_by?(current_user)

    if @comment.save
      render json: Api::V1::CommentSerializer.new(@comment, @options), status: :accepted
    else
      api_error(status: 422, errors: @comment.errors)
    end
  end

  # PUT /api/v1/comments/:id/delete
  def delete
    security_transgression_unless @comment.can_be_deleted_by?(current_user)

    if @comment.delete_by(current_user)
      render json: {}, status: :no_content
    else
      api_error(status: 409, errors: "already deleted")
    end
  end

  # PUT /api/v1/comments/:id/undelete
  def undelete
    security_transgression_unless @comment.can_be_deleted_by?(current_user)

    if @comment.undelete_by(current_user)
      render json: Api::V1::CommentSerializer.new(@comment, @options)
    else
      api_error(status: 404, errors: "comment does not exists")
    end
  end

  # PUT /api/v1/comments/:id/upvote
  def upvote
    security_transgression_unless @comment.can_be_voted_on_by?(current_user)

    @comment.upvote_from current_user
    render json: { message: "comment upvoted" }
  end

  # PUT /api/v1/comments/:id/downvote
  def downvote
    security_transgression_unless @comment.can_be_voted_on_by?(current_user) &&
                                  @comment.thread.config.comment_voting.to_sym == :ld

    @comment.downvote_from current_user
    render json: { message: "comment downvoted" }
  end

  # PUT /api/v1/comments/:id/unvote
  def unvote
    security_transgression_unless @comment.can_be_voted_on_by?(current_user)

    @comment.unvote voter: current_user
    render json: { message: "comment unvoted" }
  end

  private

    def load_index_resource
      @commontator_thread = Commontator::Thread.find(params[:thread_id])
      @project = @commontator_thread.commontable
      security_transgression_unless @project.project_access_type == "Public" \
                                    || (current_user && @project.author == current_user \
                                    && @commontator_thread.can_be_read_by?(current_user))
    end

    def load_create_resource
      @commontator_thread = Commontator::Thread.find(params[:thread_id])
      security_transgression_unless @commontator_thread.can_be_read_by? current_user

      @comment = Commontator::Comment.new(
        thread: @commontator_thread, creator: current_user, body: params.dig(:comment, :body)
      )
      security_transgression_unless @comment.can_be_created_by?(current_user)
    end

    def set_comment_and_thread
      @comment = Commontator::Comment.find(params[:id])
      @commontator_thread = @comment.thread
    end

    def set_options
      @options = {}
      @options[:params] = { current_user: current_user }
    end
end
