class AddUniqueIndexToTagsName < ActiveRecord::Migration[8.0]
  def change
    add_index :tags, :name, unique: true
  end
end
