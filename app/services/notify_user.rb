# frozen_string_literal: true

class NotifyUser
  Result = Struct.new(:success, :type, :first_param, :second)
  def initialize(notification_id:)
    @notification = NoticedNotification.find(notification_id)
    @assignment = @notification.params[:assignment]
    @project = @notification.params[:project]
  end

  def call
    type_check
  end

  private

    def type_check
      if @notification.type == "StarNotification" # rubocop:disable Style/CaseLikeIf
        Result.new("true", "star", @project.author, @project)
      elsif @notification.type == "ForkNotification"
        Result.new("true", "fork", @project.author, @project)
      elsif @notification.type == "NewAssignmentNotification"
        Result.new("true", "new_assignment", @assignment.group, @assignment)
      else
        Result.new("false", "no_type")
      end
    end
end
