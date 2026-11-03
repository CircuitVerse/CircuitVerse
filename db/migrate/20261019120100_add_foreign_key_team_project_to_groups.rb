# frozen_string_literal: true

class AddForeignKeyTeamProjectToGroups < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :groups, :projects, column: :team_project_id, on_delete: :nullify, validate: false
  end
end
