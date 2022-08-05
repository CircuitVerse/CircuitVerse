class PopulateNotificationData < ActiveRecord::Migration[7.0]
  include ActivityNotification
  def change
    Notification.find_each do |data|
      newnotification = NoticedNotification.first_or_initialize(
        :recipient_type => data.target_type,
        :recipient_id => data.target_id,
        :type => "PreviousNotification",
        :params => {
          user_id: data.notifier_id,
          path: data.notifiable_path
        },
        :read_at => data.opened_at
      )
      newnotification.save!
    end
  end
end
