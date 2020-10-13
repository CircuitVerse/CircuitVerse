class CreateAnnouncements < ActiveRecord::Migration[6.0]
  def change
    create_table :announcements do |t|
      t.text :body
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
