class AddLtiTokenToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :lti_token, :string
  end
end
