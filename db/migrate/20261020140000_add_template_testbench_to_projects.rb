# frozen_string_literal: true

class AddTemplateTestbenchToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :template_testbench, :jsonb
  end
end
