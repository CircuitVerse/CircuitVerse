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

    add_check_constraint :organizations, "char_length(trim(name)) > 0", name: "organizations_name_not_blank"
    add_check_constraint :organizations, "char_length(trim(slug)) > 0", name: "organizations_slug_not_blank"

    add_index :organizations, :slug,
              unique: true,
              where: "deleted_at IS NULL"

    add_index :organizations,
              "lower(email_domain)",
              unique: true,
              where: "email_domain IS NOT NULL AND deleted_at IS NULL",
              name: "index_organizations_on_lower_email_domain_active_unique"

    add_index :organizations, :deleted_at
  end
end