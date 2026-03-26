# frozen_string_literal: true

class CreateLtiPlatforms < ActiveRecord::Migration[8.0]
  def change
    create_table :lti_platforms do |t|
      t.string :issuer,        null: false
      t.string :client_id,     null: false
      t.string :auth_url,      null: false
      t.string :token_url,     null: false
      t.string :jwks_url,      null: false
      t.string :deployment_id
      t.timestamps
    end
    # Index added inside create_table transaction is safe for new tables
    add_index :lti_platforms, [:issuer, :client_id],
              unique: true,
              name: "index_lti_platforms_on_issuer_and_client_id"
  end
end
