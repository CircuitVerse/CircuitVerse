# frozen_string_literal: true

class AddRosterSyncToGroups < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :groups, :lti_resource_link, foreign_key: false, index: { algorithm: :concurrently }
    add_column :groups, :last_synced_at, :datetime
  end
end
