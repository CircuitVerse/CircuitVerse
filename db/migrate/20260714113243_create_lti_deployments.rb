# frozen_string_literal: true

class CreateLtiDeployments < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_deployments do |t|
      t.string :issuer,           null: false
      t.string :client_id,        null: false
      t.string :deployment_id,    null: false
      t.string :auth_login_url,   null: false
      t.string :access_token_url, null: false
      t.string :jwks_url,         null: false

      t.timestamps
    end

    add_index :lti_deployments, %i[issuer client_id deployment_id],
              unique: true, name: "index_lti_deployments_on_platform_and_deployment"
  end
end
