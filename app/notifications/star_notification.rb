# To deliver this notification:
#
# StarNotification.with(post: @post).deliver_later(current_user)
# StarNotification.with(post: @post).deliver(current_user)

class StarNotification < Noticed::Base
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
    "#{user.name} starred your Project '#{project.name}'"
  end

  def url
    project = Project.find(params[:project][:id])
    user_project_path(project.author, project)
  end
end
