class DropDifficultyLevelsTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :difficulty_levels
  end

  def down
    create_table :difficulty_levels do |t|
      t.string :name
      t.timestamps
    end
  end
end
