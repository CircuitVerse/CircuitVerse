class AddFeaturedCircuits < ActiveRecord::Migration[5.1]
  def change
    create_table :featured_circuits
    add_reference :featured_circuits, :project, foreign_key: true
  end
end
