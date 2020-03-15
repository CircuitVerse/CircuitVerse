require 'rails_helper'

module Commontator
  RSpec.describe Subscription, type: :model do
    before(:each) do
      setup_model_spec
      @subscription = Subscription.new
      @subscription.thread = @thread
      @subscription.subscriber = @user
      @subscription.save!
    end
    
    it 'must count unread comments' do
      expect(@subscription.unread_comments.count).to eq 0

      comment = Comment.new
      comment.thread = @thread
      comment.creator = @user
      comment.body = 'Something'
      comment.save!

      expect(@subscription.reload.unread_comments.count).to eq 1

      comment = Comment.new
      comment.thread = @thread
      comment.creator = @user
      comment.body = 'Something else'
      comment.save!

      expect(@subscription.reload.unread_comments.count).to eq 2

      @subscription.touch

      expect(@subscription.reload.unread_comments.count).to eq 0
    end
  end
end

