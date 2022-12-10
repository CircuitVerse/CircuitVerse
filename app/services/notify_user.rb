# frozen_string_literal: true

class NotifyUser
  Result = Struct.new(:success, :type, :first_param, :second)
  def initialize(params)
    @notification = NoticedNotification.find(params[:notification_id])
    @project = @notification.params[:project]
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
      elsif @notification.type == "NewGroupNotification"
        @group = @notification.params[:group][:group_id]
        Result.new("true", "new_group", @group)
      else
        Result.new("false", "no_type", root_path)
      end
    end
end
