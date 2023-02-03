class AddFieldsToAssignments < ActiveRecord::Migration[6.0]
  def change
    add_column :assignments, :lti_consumer_key, :string
    add_column :assignments, :lti_shared_secret, :string
  end
end
