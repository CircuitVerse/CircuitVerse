# frozen_string_literal: true

class AddOrganizationToGroups < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :groups, :organization,
                  index: { algorithm: :concurrently },
                  _skip_validate_options: true
  end
end
