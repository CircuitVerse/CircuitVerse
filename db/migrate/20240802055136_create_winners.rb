class CreateWinners < ActiveRecord::Migration[7.0]
  def change
    create_table :winners do |t|
      t.references :contest, foreign_key: true
      t.references :submission, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
