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
    @contest = @notification.params[:contest]  # Added to handle ContestNotification
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
      star_notification
    when "ForkNotification"
      fork_notification
    when "NewAssignmentNotification"
      new_assignment_notification
    when "ForumCommentNotification"
      forum_comment_notification
    when "ForumThreadNotification"
      forum_thread_notification
    when "ContestNotification"
      contest_notification
    when "ContestWinnerNotification"
      contest_winner_notification
    else
      Result.new("false", "no_type", root_path)
    end
  end

  def star_notification
    Result.new("true", "star", @project.author, @project)
  end

  def fork_notification
    Result.new("true", "fork", @project.author, @project)
  end

  def new_assignment_notification
    Result.new("true", "new_assignment", @assignment.group, @assignment)
  end

  def forum_comment_notification
    @post = @notification.params[:forum_post]
    Result.new("true", "forum_comment", @thread, @post.id)
  end

  def forum_thread_notification
    Result.new("true", "forum_thread", @thread)
  end

  def contest_notification
    Result.new("true", "new_contest", @contest)
  end

  def contest_winner_notification
    Result.new("true", "contest_winner")
  end
end
