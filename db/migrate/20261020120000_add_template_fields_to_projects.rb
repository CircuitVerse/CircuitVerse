# frozen_string_literal: true

class AddTemplateFieldsToProjects < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      change_table :projects, bulk: true do |t|
        t.boolean :is_template, default: false, null: false
        t.integer :template_visibility, default: 0, null: false
      end
    end
  end
end
