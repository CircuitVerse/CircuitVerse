# frozen_string_literal: true

class NotifyUser
  Result = Struct.new(:success, :type, :first_param, :second)
  def initialize(params)
    @notification = NoticedNotification.find(params[:notification_id])
    @assignment = @notification.params[:assignment]
    @project = @notification.params[:project]
    @thread = @notification.params[:forum_thread]
  end

  def call
    result = type_check
    return result if result.success == "true"

    false
  end

  private

    def type_check
      if @notification.type == "StarNotification" # rubocop:disable Style/CaseLikeIf
        Result.new("true", "star", @project.author, @project)
      elsif @notification.type == "ForkNotification"
        Result.new("true", "fork", @project.author, @project)
      elsif @notification.type == "NewAssignmentNotification"
        Result.new("true", "new_assignment", @assignment.group, @assignment)
      elsif @notification.type == "ForumCommentNotification"
        @post = @notification.params[:forum_post]
        Result.new("true", "forum_comment", @thread, @post.id)
      elsif @notification.type == "ForumThreadNotification"
        Result.new("true", "forum_thread", @thread)
      else
        Result.new("false", "no_type", root_path)
      end
    end
end
