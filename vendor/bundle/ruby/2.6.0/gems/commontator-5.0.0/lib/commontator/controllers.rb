require 'commontator/shared_helper'
require 'commontator/security_transgression'

module Commontator
  module Controllers
    def self.included(base)
      base.helper Commontator::SharedHelper
    end
    
    protected

    def commontator_set_new_comment(thread, user)
      return if thread.nil? || thread.config.new_comment_style != :t
      new_comment = Comment.new
      new_comment.thread = thread
      new_comment.creator = user
      @new_comment = new_comment if new_comment.can_be_created_by?(user)
    end
    
    def commontator_thread_show(commontable)
      user = Commontator.current_user_proc.call(self)	
      thread = commontable.thread
      raise Commontator::SecurityTransgression unless thread.can_be_read_by?(user)
      thread.mark_as_read_for(user)
      @commontator_page = params[:page] || 1
      @commontator_per_page = params[:per_page] || thread.config.comments_per_page
      @commontator_thread_show = true
      commontator_set_new_comment(thread, user)
    end
  end
end

ActionController::Base.send :include, Commontator::Controllers
