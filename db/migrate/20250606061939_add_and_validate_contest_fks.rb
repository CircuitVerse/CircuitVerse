# frozen_string_literal: true

class AddAndValidateContestFks < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_fk_if_missing :submission_votes, :users,    :user_id
      add_fk_if_missing :submissions,      :projects, :project_id
      add_fk_if_missing :submissions,      :users,    :user_id
      add_fk_if_missing :contest_winners,  :projects, :project_id
    end

    validate_foreign_key :submission_votes, :users
    validate_foreign_key :submissions,      :projects
    validate_foreign_key :submissions,      :users
    validate_foreign_key :contest_winners,  :projects
  end

  def down
    safety_assured do
      remove_fk_if_exists :contest_winners,  :projects, :project_id
      remove_fk_if_exists :submissions,      :users,    :user_id
      remove_fk_if_exists :submissions,      :projects, :project_id
      remove_fk_if_exists :submission_votes, :users,    :user_id
    end
  end

  private

  def add_fk_if_missing(from_table, to_table, column)
    return if foreign_key_exists?(from_table, to_table, column: column)

    add_foreign_key from_table, to_table,
                    column:   column,
                    validate: false
  end

  def remove_fk_if_exists(from_table, to_table, column)
    return unless foreign_key_exists?(from_table, to_table, column: column)

    remove_foreign_key from_table, to_table, column: column
  end
end
