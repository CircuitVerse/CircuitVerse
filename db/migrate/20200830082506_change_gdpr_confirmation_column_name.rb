class ChangeGdprConfirmationColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :privacy_confirmation, :accepted_privacy_policy
  end
end
