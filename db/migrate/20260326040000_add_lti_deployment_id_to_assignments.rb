# frozen_string_literal: true

class AddLtiDeploymentIdToAssignments < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :assignments, :lti_deployment_id, :string, null: true
    add_index  :assignments, :lti_deployment_id, algorithm: :concurrently
  end
end
