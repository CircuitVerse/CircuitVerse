class RemoveDifficultyLevelIdFromQuestions < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      remove_foreign_key :questions, :difficulty_levels if foreign_key_exists?(:questions, :difficulty_levels)
      remove_column :questions, :difficulty_level_id if column_exists?(:questions, :difficulty_level_id)
    end
  end
end
