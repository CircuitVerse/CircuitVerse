class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string   :name,                         null: false
      t.string   :slug,                         null: false
      t.text     :description
      t.string   :email_domain
      t.string   :oidc_issuer_url
      t.string   :oidc_client_id
      t.text     :oidc_client_secret_ciphertext
      t.datetime :deleted_at
      t.timestamps null: false
    end

    add_index :organizations, :slug,         unique: true
    add_index :organizations, :email_domain
    add_index :organizations, :deleted_at
  end
end