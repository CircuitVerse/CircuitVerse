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

    def type_check
      case @notification.type
      when "NewGroupNotification"
        handle_group_notification
      when "StarNotification", "ForkNotification"
        Result.new("true", @notification.type[0, 4].downcase, @project.author, @project)
      when "NewAssignmentNotification"
        Result.new("true", "new_assignment", @assignment.group, @assignment)
      when "ForumCommentNotification"
        handle_forum_comment
      when "ForumThreadNotification"
        Result.new("true", "forum_thread", @thread)
      else
        Result.new("false", "no_type", root_path)
      end
    end

    def handle_group_notification
      @group = @notification.params[:group][:group_id]
      Result.new("true", "new_group", @group, 1)
    end

    def handle_forum_comment
      @post = @notification.params[:forum_post]
      Result.new("true", "forum_comment", @thread, @post.id)
    end
end
