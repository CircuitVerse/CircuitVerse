class PopulateNoticedNotificationWithValidParams < ActiveRecord::DataMigration
  def up
    NoticedNotification.find_each do |notification|
      if Project.where(id: notification.params[:project_id]).exists?
        project = Project.find(notification.params[:project_id])
        notification.params[:user] = User.find(notification.params[:user_id])
        notification.params[:project] = project
        notification.save
      else
        notification.destroy!
      end
     rescue ActiveRecord::RecordNotFound => e
      puts e.message
    end
  end
end
