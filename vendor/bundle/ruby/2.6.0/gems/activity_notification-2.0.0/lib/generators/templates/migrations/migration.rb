# Migration responsible for creating a table with notifications
class <%= @migration_name %> < ActiveRecord::Migration<%= Rails::VERSION::MAJOR >= 5 ? "[#{Rails.version.to_f}]" : "" %>
  # Create tables
  def change
    <% if @migration_tables.include?('notifications') %>create_table :notifications do |t|
      t.belongs_to :target,     polymorphic: true, index: true, null: false
      t.belongs_to :notifiable, polymorphic: true, index: true, null: false
      t.string     :key,                                        null: false
      t.belongs_to :group,      polymorphic: true, index: true
      t.integer    :group_owner_id,                index: true
      t.belongs_to :notifier,   polymorphic: true, index: true
      t.text       :parameters
      t.datetime   :opened_at

      t.timestamps null: false
    end<% else %># create_table :notifications do |t|
    #   t.belongs_to :target,     polymorphic: true, index: true, null: false
    #   t.belongs_to :notifiable, polymorphic: true, index: true, null: false
    #   t.string     :key,                                        null: false
    #   t.belongs_to :group,      polymorphic: true, index: true
    #   t.integer    :group_owner_id,                index: true
    #   t.belongs_to :notifier,   polymorphic: true, index: true
    #   t.text       :parameters
    #   t.datetime   :opened_at
    #
    #   t.timestamps null: false
    # end<% end %>

    <% if @migration_tables.include?('subscriptions') %>create_table :subscriptions do |t|
      t.belongs_to :target,     polymorphic: true, index: true, null: false
      t.string     :key,                           index: true, null: false
      t.boolean    :subscribing,                                null: false, default: true
      t.boolean    :subscribing_to_email,                       null: false, default: true
      t.datetime   :subscribed_at
      t.datetime   :unsubscribed_at
      t.datetime   :subscribed_to_email_at
      t.datetime   :unsubscribed_to_email_at
      t.text       :optional_targets

      t.timestamps null: false
    end
    add_index :subscriptions, [:target_type, :target_id, :key], unique: true<% else %># create_table :subscriptions do |t|
    #   t.belongs_to :target,     polymorphic: true, index: true, null: false
    #   t.string     :key,                           index: true, null: false
    #   t.boolean    :subscribing,                                null: false, default: true
    #   t.boolean    :subscribing_to_email,                       null: false, default: true
    #   t.datetime   :subscribed_at
    #   t.datetime   :unsubscribed_at
    #   t.datetime   :subscribed_to_email_at
    #   t.datetime   :unsubscribed_to_email_at
    #   t.text       :optional_targets
    #
    #   t.timestamps null: false
    # end
    # add_index :subscriptions, [:target_type, :target_id, :key], unique: true<% end %>
  end
end
