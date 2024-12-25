class AddSearchableToUsers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :users, :searchable, :virtual, stored: true, type: :tsvector, as: <<~SQL
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(educational_institute,'')), 'B')
    SQL
    add_index :users, :searchable, using: :gin, algorithm: :concurrently
  end
end
