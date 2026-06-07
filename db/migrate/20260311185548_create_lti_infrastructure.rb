class CreateLtiInfrastructure < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :lti_deployments do |t|
      t.string :platform_id,      null: false
      t.string :deployment_id,    null: false
      t.string :client_id,        null: false
      t.string :issuer,           null: false
      t.string :jwks_url,         null: false
      t.string :access_token_url, null: false
      t.string :auth_login_url,   null: false
      t.timestamps
    end

    add_index :lti_deployments,
              [:platform_id, :deployment_id],
              unique: true,
              name: "index_lti_deployments_unique"

    add_reference :assignments, :lti_deployment,
                  null: true,
                  index: { algorithm: :concurrently }

    add_column :assignments, :lti_version,
               :integer, null: false, default: 0

    add_column :assignments, :canvas_assignment_id,
               :string, null: true
  end
end
