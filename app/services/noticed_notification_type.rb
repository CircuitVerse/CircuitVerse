# frozen_string_literal: true

class NoticedNotificationType
    def initialize(params)
          @notification = NoticedNotification.find(params[:notification_id])
          # @assignment = @notification.params[:assignment]
          # @group = @assignment.group
          # @project = @notification.params[:project]
      end

  def notification_type
    if @notification.type == "NewAssignmentNotification"
        # @group = @assignment.group
        # redirect_to group_assignment_path(@group, @assignment)
        return true
      else
        # @project = @notification.params[:project]
        # redirect_to user_project_path(@project.author, @project)
        return false
      end  
  end

    def notify
      return true  if @notification.type == "NewAssignmentNotification"
      false 
    end
end
