# frozen_string_literal: true

class AddForeignKeyLtiResourceLinkToGroups < ActiveRecord::Migration[8.1]
  def change
    # New column, all values NULL: validate: false is safe here (matches
    # 20260518215840 for the organization FK).
    add_foreign_key :groups, :lti_resource_links, validate: false
  end
end
