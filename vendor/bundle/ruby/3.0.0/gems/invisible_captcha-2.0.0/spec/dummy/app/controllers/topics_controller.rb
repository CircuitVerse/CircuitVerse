class TopicsController < ApplicationController
  invisible_captcha honeypot: :subtitle, only: :create

  invisible_captcha honeypot: :subtitle, only: :update,
                              on_spam: :custom_callback,
                              on_timestamp_spam: :custom_timestamp_callback

  invisible_captcha honeypot: :subtitle, only: :publish, timestamp_threshold: 2

  invisible_captcha honeypot: :subtitle, only: :copy, timestamp_enabled: false

  def index
    redirect_to new_topic_path
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(params[:topic])

    if @topic.valid?
      redirect_to new_topic_path(context: params[:context]), notice: 'Topic valid!'
    else
      render action: 'new'
    end
  end

  def update
  end

  def publish
    redirect_to new_topic_path
  end

  def copy
    @topic = Topic.new(params[:topic])

    if @topic.valid?
      redirect_to new_topic_path(context: params[:context]), notice: 'Success!'
    else
      render action: 'new'
    end
  end

  private

  def custom_callback
    redirect_to new_topic_path
  end

  def custom_timestamp_callback
    head(204)
  end
end
