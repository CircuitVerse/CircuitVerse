class AddMentorToGroupMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :group_members, :mentor, :boolean, default: false
  end
end
