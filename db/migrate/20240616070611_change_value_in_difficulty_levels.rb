class ChangeValueInDifficultyLevels < ActiveRecord::Migration[6.1]
  def change
    change_column :difficulty_levels, :value, :integer, using: 'value::integer'
  end
end
