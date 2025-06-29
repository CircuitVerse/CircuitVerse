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

  def down; end

  private

  def add_fk_if_missing(from_table, to_table, column)
    return if foreign_key_exists?(from_table, to_table, column: column)

    add_foreign_key from_table, to_table,
                    column:   column,
                    validate: false
  end
end
