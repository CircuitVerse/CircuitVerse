class AddCircuitElements < ActiveRecord::Migration[5.1]
  def change
    create_table :circuit_elements do |t|
      t.string :name
      t.string :image
      t.integer :category
      t.timestamps
    end

    create_table :assignments_circuit_elements, id: false do |t|
      t.belongs_to :circuit_element, index: true
      t.belongs_to :assignment, index: true
    end
  end
end
