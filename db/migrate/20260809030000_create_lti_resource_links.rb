# frozen_string_literal: true

class CreateLtiResourceLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :lti_resource_links do |t|
      t.references :lti_deployment, null: false, foreign_key: true, index: false
      t.string :resource_link_id, null: false
      t.string :context_id
      t.string :title
      t.string :lineitems_url
      t.string :lineitem_url
      t.string :context_memberships_url

      t.timestamps
    end

    add_index :lti_resource_links, %i[lti_deployment_id resource_link_id],
              unique: true, name: "index_lti_resource_links_on_deployment_and_link"
  end
end
