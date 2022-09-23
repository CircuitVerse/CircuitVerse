class CreateContests < ActiveRecord::Migration[7.0]
  def change
    create_table :contests do |t|
      t.datetime :deadline
      t.string :status

      t.timestamps
    end
  end
end
