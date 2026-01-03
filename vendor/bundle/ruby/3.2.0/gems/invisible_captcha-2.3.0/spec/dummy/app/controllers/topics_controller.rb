class TopicsController < ApplicationController
  invisible_captcha honeypot: :subtitle, only: :create

  invisible_captcha honeypot: :subtitle, only: :update,
                              on_spam: :custom_callback,
                              on_timestamp_spam: :custom_timestamp_callback

  invisible_captcha honeypot: :subtitle, only: :publish, timestamp_threshold: 2

  invisible_captcha honeypot: :subtitle, only: :copy, timestamp_enabled: false

  invisible_captcha scope: :topic, only: :rename

  invisible_captcha only: :categorize

  invisible_captcha honeypot: :subtitle, only: :test_passthrough,
    on_spam: :catching_on_spam_callback,
    on_timestamp_spam: :on_timestamp_spam_callback_with_passthrough

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
    redirect_to new_topic_path
  end

  def rename
  end

  def categorize
    redirect_to new_topic_path
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

  def test_passthrough
    redirect_to new_topic_path
  end

  private

  def custom_callback
    redirect_to new_topic_path
  end

  def custom_timestamp_callback
    head(204)
  end

  def on_timestamp_spam_callback_with_passthrough
  end

  def catching_on_spam_callback
    head(204)
  end

end
