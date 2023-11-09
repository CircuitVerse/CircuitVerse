# frozen_string_literal: true

class AddUniqueGradeValidation < ActiveRecord::Migration[6.0]
  def change
    add_index :grades, %i[project_id assignment_id], unique: true
  end
end
