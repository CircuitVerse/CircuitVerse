class DestroyNotificationsForNonExistingNotifierUser < ActiveRecord::DataMigration
  def up
    NoticedNotification.find_each do |notification|
      if !User.where(id: notification.params[:user]).exists?
        notification.destroy!
      end
      rescue ActiveRecord::RecordNotFound => e
        if !User.where(id: e.id).exists?
          notification.destroy!
        end
        puts !User.where(id: e.id).exists?
    end
  end
end