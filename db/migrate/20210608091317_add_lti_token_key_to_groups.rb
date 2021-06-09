class AddLtiTokenKeyToGroups < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :lti_token_key, :string
  end
end
