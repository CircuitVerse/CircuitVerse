# frozen_string_literal: true

class NotifyUser
  Result = Struct.new(:success, :type, :first_param, :second)
  def initialize(params)
    @notification = NoticedNotification.find(params[:notification_id])
    @project = @notification.params[:project]
    @assignment = @notification.params[:assignment]
    @thread = @notification.params[:forum_thread]
  end

  def call
    result = type_check
    return result if result.success == "true"

    false
  end

  private

    def type_check # robocop:disable Metrics/MethodLength
      case @notification.type
      when "NewGroupNotification"
        @group = @notification.params[:group][:group_id]
        Result.new("true", "new_group", @group, 1)
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
        Result.new("false", "no_type", root_path)
      end
    end
end
