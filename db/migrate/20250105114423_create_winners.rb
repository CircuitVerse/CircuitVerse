class CreateWinners < ActiveRecord::Migration[7.0]
  def change
    create_table :contest_winners do |t|
      t.references :contest, foreign_key: true
      t.references :submission, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
