# frozen_string_literal: true

class NotifyUser
  Result = Struct.new(:success, :type, :first_param, :second)

  # @param [Hash] params
  def initialize(params)
    # @type [NoticedNotification]
    @notification = NoticedNotification.find(params[:notification_id])
    # @type [Assignment]
    @assignment = @notification.params[:assignment]
    # @type [Project]
    @project = @notification.params[:project]
    @thread = @notification.params[:forum_thread]
  end

  # @return [Boolean]
  def call
    result = type_check
    return result if result.success == "true"

    false
  end

  private

    # @return [Result]
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
        Result.new("false", "no_type", root_path)
      end
    end
end
