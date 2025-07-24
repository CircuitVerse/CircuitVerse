# frozen_string_literal: true

class ValidateProjectsGroupForeignKey < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :projects, :groups
  end
end
