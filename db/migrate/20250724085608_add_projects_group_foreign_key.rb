# frozen_string_literal: true

class AddProjectsGroupForeignKey < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :projects, :groups, validate: false
  end
end
