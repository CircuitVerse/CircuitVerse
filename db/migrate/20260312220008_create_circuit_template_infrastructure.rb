class CreateCircuitTemplateInfrastructure < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    create_table :circuit_templates do |t|
      t.string     :name,          null: false
      t.text       :description
      t.jsonb      :circuit_data,  null: false, default: {}
      t.references :created_by,    null: false,
                   index: { algorithm: :concurrently }
      t.boolean    :public,        null: false, default: false
      t.timestamps
    end

    create_table :assignment_test_cases do |t|
      t.references :assignment,      null: false,
                   foreign_key: true,
                   index: { algorithm: :concurrently }
      t.string     :description,     null: false
      t.jsonb      :input_pins,      null: false, default: {}
      t.jsonb      :expected_output, null: false, default: {}
      t.integer    :position,        null: false, default: 0
      t.timestamps
    end

    add_reference :assignments, :circuit_template,
                  null: true,
                  index: { algorithm: :concurrently }
  end
end
