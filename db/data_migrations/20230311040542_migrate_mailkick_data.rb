class MigrateMailkickData < ActiveRecord::DataMigration
  def up
    opted_out_emails = Mailkick::Legacy.opted_out_emails(list: nil)
    opted_out_users = Mailkick::Legacy.opted_out_users(list: nil)

    User.find_in_batches do |users|
      users.reject! { |u| opted_out_emails.include?(u.email) }
      users.reject! { |u| opted_out_users.include?(u) }

      now = Time.now
      records =
        users.map do |user|
          {
            subscriber_type: user.class.name,
            subscriber_id: user.id,
            list: "circuitverse",
            created_at: now,
            updated_at: now
          }
        end
      Mailkick::Subscription.insert_all!(records)
    end
  end
end
