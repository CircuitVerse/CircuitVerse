class ResetAllGroupsCacheCounters < ActiveRecord::Migration[6.0]
  def change
    Group.all.each do |group|
      Group.reset_counters(group.id, :group_members)
    end
  end
end
