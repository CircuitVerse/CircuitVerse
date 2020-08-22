class AddGroupMembersCountToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :group_members_count, :integer
  end
end
