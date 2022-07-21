# frozen_string_literal: true

class ForkNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :post

  # Define helper methods to make rendering easier.
  #
  def message
    user = User.find(params[:user][:id])
    project = Project.find(params[:project][:id])
    "#{user.name} Forked your Project '#{project.name}'"
  end

  def icon
    "fas fa-code-branch"
  end

  def url
    project = Project.find(params[:project][:id])
    user_project_path(project.author, project)
  end
end
