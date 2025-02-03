class AddingIndexes < ActiveRecord::Migration[5.1]
  def change
    add_index(:group_members,[:group_id,:user_id],unique:true)
    add_index(:pending_invitations,[:group_id,:email],unique:true)
    add_index(:stars,[:user_id,:project_id],unique:true)
  end
end
