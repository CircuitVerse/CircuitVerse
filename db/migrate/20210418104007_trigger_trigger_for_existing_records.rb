class TriggerTriggerForExistingRecords < ActiveRecord::Migration[6.0]
  def change
    Project.connection.execute("UPDATE projects set name = name")
  end
end
