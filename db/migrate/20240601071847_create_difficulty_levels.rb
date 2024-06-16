class CreateDifficultyLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :difficulty_levels do |t|
      t.integer :difficulty_level, default: 0 
      t.timestamps
    end
  end
end
