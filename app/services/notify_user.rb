# frozen_string_literal: true

class NotifyUser
  Result = Struct.new(:success, :type, :first_param, :second)
  def initialize(notification_id:)
    @notification = NoticedNotification.find(notification_id)
    @assignment = @notification.params[:assignment]
    @project = @notification.params[:project]
    @thread = @notification.params[:forum_thread]
  end

  def call
    type_check
  end

  private

    def type_check
      case @notification.type
      when "StarNotification"
        Result.new("true", "star", @project.author, @project)
      when "ForkNotification"
        Result.new("true", "fork", @project.author, @project)
      when "NewAssignmentNotification"
        Result.new("true", "new_assignment", @assignment.group, @assignment)
      when "ForumCommentNotification"
        @post = @notification.params[:forum_post]
        Result.new("true", "forum_comment", @thread, @post.id)
      when "ForumThreadNotification"
        Result.new("true", "forum_thread", @thread)
      else
        Result.new("false", "no_type")
      end
    end
end
