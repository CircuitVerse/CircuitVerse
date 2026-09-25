# frozen_string_literal: true

class AddNotNullConstraintsToBooleanColumns < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_column_null :submissions, :winner, false, false
      change_column_null :users, :admin, false, false
      change_column_null :users, :subscribed, false, true
      change_column_null :projects, :project_submission, false, false
      change_column_null :group_members, :mentor, false, false
      change_column_null :custom_mails, :sent, false, false
      change_column_null :assignments, :grades_finalized, false, false
    end
  end
end
