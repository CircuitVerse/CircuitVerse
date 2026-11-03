# frozen_string_literal: true

class AddTeamProjectToGroups < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :groups, :team_project, foreign_key: false, index: { algorithm: :concurrently }
  end
end
