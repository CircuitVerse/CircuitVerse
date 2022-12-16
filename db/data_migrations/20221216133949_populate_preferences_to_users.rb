class PopulatePreferencesToUsers < ActiveRecord::DataMigration
  def up
    User.all.update!(star: "true", fork: "true")
  end
end
