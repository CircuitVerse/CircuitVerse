class CreateContests < ActiveRecord::Migration[7.0]
  def change
    create_table :contests do |t|
      t.jsonb :winners
      t.integer :contest_submissions_count
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :live, :default => false

      t.timestamps
    end
  end
end
