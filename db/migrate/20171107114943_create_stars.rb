class CreateStars < ActiveRecord::Migration[5.1]
  def change
    create_table :stars do |t|
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
