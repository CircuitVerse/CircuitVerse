class PopulateNotificationData < ActiveRecord::Migration[7.0]
  include ActivityNotification
  def change
    Notification.all.each do |data|
      newnotification = NoticedNotification.create(
        :recipient_type => data.target_type,
        :recipient_id => data.target_id,
        :type => (data.notifiable_type == "Star" ? "StarNotification" : "ForkNotification"),
        :params => {
          user_id: data.notifier_id,
          project_id: data.notifiable.id,
          migrated: true
        },
        :read_at => data.opened_at
      )
    end
  end
end
