class CreateAnnouncements < ActiveRecord::Migration[6.0]
  def change
    create_table :announcements do |t|
      t.text :body
      t.text :link
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
