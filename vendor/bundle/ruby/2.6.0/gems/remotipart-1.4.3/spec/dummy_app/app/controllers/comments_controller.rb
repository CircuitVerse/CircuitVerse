class CommentsController < ApplicationController
  def index
    @comments = Comment.all
    respond_to do |format|
      format.html
      format.json { render json: @comments }
    end
  end

  def show
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @comment }
    end
  end

  def new
    @comment = Comment.new
    respond_to do |format|
      format.html { render :layout => ! request.xhr? }
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @comment }
    end
  end

  def create
    @comment = Comment.create(comment_params)
    if request.xhr? || remotipart_submitted?
      sleep 1 if params[:pause]
      respond_to do |format|
        format.html { render (params[:template] == 'escape' ? 'comments/escape_test' : 'comments/create'), layout: false }
        format.js { render 'comments/create', layout: false, status:(@comment.errors.any? ? :unprocessable_entity : :ok) }
        format.json { render json: @comment }
      end
    else
      redirect_to comments_path
    end
  end

  def update
    @comment = Comment.find(params[:id])
    respond_to do |format|
      format.html { redirect_to @comment }
      format.js { render json: @comment }
    end
  end

  def destroy
    @comment = Comment.destroy(params[:id])
  end

  def say
    if Rails.version < '4'
      render text: params[:message], content_type: 'text/plain'
    else
      render plain: params[:message]
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:subject, :body, :attachment, :other_attachment)
  end
end
