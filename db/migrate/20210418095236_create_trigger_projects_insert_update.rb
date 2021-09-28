# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggerProjectsInsertUpdate < ActiveRecord::Migration[6.0]
  def up
    create_trigger("projects_after_insert_update_row_tr", :generated => true, :compatibility => 1).
        on("projects").
        before(:insert, :update).nowrap do
      <<~SQL
      tsvector_update_trigger(
        searchable, 'pg_catalog.english', description, name
      );
      SQL
    end
  end

  def down
    drop_trigger("projects_after_insert_update_row_tr", "projects", :generated => true)
  end
end
