# frozen_string_literal: true

class CreateLtiDeployments < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_deployments do |t|
      t.string :platform_id,       null: false
      t.string :deployment_id,     null: false
      t.string :client_id,         null: false
      t.string :issuer,            null: false
      t.string :jwks_url,          null: false
      t.string :access_token_url,  null: false
      t.string :auth_login_url,    null: false
      t.text   :platform_public_key

      t.timestamps
    end

    add_index :lti_deployments, [:platform_id, :deployment_id],
              unique: true, name: "index_lti_deployments_unique"
  end
end
