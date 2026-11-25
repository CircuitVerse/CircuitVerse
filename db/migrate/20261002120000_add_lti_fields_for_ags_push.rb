# frozen_string_literal: true

class AddLtiFieldsForAgsPush < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :assignments, :lti_resource_link, index: { algorithm: :concurrently }
    add_foreign_key :assignments, :lti_resource_links, validate: false
    add_column :users, :lti_sub, :string
  end
end
