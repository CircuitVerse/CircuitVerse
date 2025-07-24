# frozen_string_literal: true

class AddGroupToProjects < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_reference :projects,
                  :group,
                  type: :bigint,
                  index: { algorithm: :concurrently }
  end
end
