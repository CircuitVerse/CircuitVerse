# frozen_string_literal: true

class Api::V1::CommentsController < Api::V1::BaseController
  before_action :authenticate_user!, except: %i[index]
  before_action :load_resource
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

  # GET /api/v1/comments/:id
  def show
    security_transgression_unless @commontator_thread.can_be_read_by? current_user

    render json: Api::V1::CommentSerializer.new(@comment, @options)
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
    render json: { "message": "comment upvoted" }
  end

  # PUT /api/v1/comments/:id/downvote
  def downvote
    security_transgression_unless @comment.can_be_voted_on_by?(current_user) && \
                                  @comment.thread.config.comment_voting.to_sym == :ld

    @comment.downvote_from current_user
    render json: { "message": "comment downvoted" }
  end

  # PUT /api/v1/comments/:id/unvote
  def unvote
    security_transgression_unless @comment.can_be_voted_on_by?(current_user)

    @comment.unvote voter: current_user
    render json: { "message": "comment unvoted" }
  end

  private

    # rubocop:disable Metrics/AbcSize
    def load_resource
      case params[:action].to_sym
      when :index
        @commontator_thread = Commontator::Thread.find(params[:thread_id])
        security_transgression_unless @commontator_thread.can_be_read_by? current_user
      when :create
        @commontator_thread = Commontator::Thread.find(params[:thread_id])
        security_transgression_unless @commontator_thread.can_be_read_by? current_user

        @comment = Commontator::Comment.new(
          thread: @commontator_thread, creator: current_user, body: params.dig(:comment, :body)
        )
        security_transgression_unless @comment.can_be_created_by?(current_user)
      else
        @comment = Commontator::Comment.find(params[:id])
        @commontator_thread = @comment.thread
      end
    end
    # rubocop:enable Metrics/AbcSize

    def set_options
      @options = {}
      @options[:params] = { current_user: current_user }
    end
end
