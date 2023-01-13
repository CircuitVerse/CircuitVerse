class PopulatePreferencesToUsers < ActiveRecord::DataMigration
  def up
    User.all.update!(star: "true", fork: "true", new_assignment: "true")
  end
end
