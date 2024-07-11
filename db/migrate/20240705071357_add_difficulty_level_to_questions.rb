class AddDifficultyLevelToQuestions < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :questions, :difficulty_level, :integer, default: 0, null: false

      reversible do |dir|
        dir.up do
          Question.reset_column_information

          # Migrate data from difficulty_level_id to difficulty_level enum
          Question.find_each do |question|
            case question[:difficulty_level_id]
            when 1
              question.update_column(:difficulty_level, 0) # easy
            when 2
              question.update_column(:difficulty_level, 1) # medium
            when 3
              question.update_column(:difficulty_level, 2) # hard
            when 4
              question.update_column(:difficulty_level, 3) # expert
            end
          end
        end
      end
    end
  end
end
