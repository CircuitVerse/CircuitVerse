class RenameCategoriesToQuestionCategories < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_table :categories, :question_categories
    end
  end
end
