# frozen_string_literal: true

class StarNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database, association: :noticed_notifications
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
    "#{user.name} starred your Project \"#{project.name}\""
  end

  def icon
    "far fa-star fa-thin"
  end

  def url
    project = Project.find(params[:project][:id])
    user_project_path(project.author, project)
  end
end
