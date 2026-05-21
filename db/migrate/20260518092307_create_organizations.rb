class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string   :name,                         null: false
      t.string   :slug,                         null: false
      t.text     :description
      t.jsonb :links, default: []
      t.boolean :private, default: true, null: false
      t.string   :logo_file_name
      t.string   :logo_content_type
      t.bigint   :logo_file_size
      t.datetime :logo_updated_at
      t.string   :oidc_issuer_url
      t.string   :oidc_client_id
      t.string   :oidc_client_secret_digest
      t.timestamps null: false
    end

    add_check_constraint :organizations, "char_length(trim(name)) > 0", name: "organizations_name_not_blank"
    add_check_constraint :organizations, "char_length(trim(slug)) > 0", name: "organizations_slug_not_blank"

    add_index :organizations,
              "lower(name)",
              unique: true,
              name: "index_organizations_on_lower_name_unique"

    add_index :organizations, :slug, unique: true
  end
end