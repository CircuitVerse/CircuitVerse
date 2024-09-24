class AddQuestionCategoriesToQuestion < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :question_category_id, :bigint
  end
end
