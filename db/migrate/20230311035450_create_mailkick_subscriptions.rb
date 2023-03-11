class CreateMailkickSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :mailkick_subscriptions do |t|
      t.references :subscriber, polymorphic: true, index: false
      t.string :list
      t.timestamps
    end

    add_index :mailkick_subscriptions, [:subscriber_type, :subscriber_id, :list], unique: true, name: "index_mailkick_subscriptions_on_subscriber_and_list"
  end
end
