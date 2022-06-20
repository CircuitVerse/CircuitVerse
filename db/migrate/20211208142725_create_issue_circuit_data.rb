class CreateIssueCircuitData < ActiveRecord::Migration[6.1]
  def change
    create_table :issue_circuit_data do |t|
      t.text :data

      t.timestamps
    end
  end
end
