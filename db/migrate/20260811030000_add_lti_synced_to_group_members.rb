# frozen_string_literal: true

class AddLtiSyncedToGroupMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :group_members, :lti_synced, :boolean, default: false, null: false
  end
end
