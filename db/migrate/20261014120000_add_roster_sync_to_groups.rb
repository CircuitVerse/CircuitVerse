# frozen_string_literal: true

class AddRosterSyncToGroups < ActiveRecord::Migration[8.1]
  def change
    add_reference :groups, :lti_resource_link, foreign_key: true
    add_column :groups, :last_synced_at, :datetime
  end
end
