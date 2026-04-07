# frozen_string_literal: true

class AddIndexToAssignmentsLtiConsumerKey < ActiveRecord::Migration[8.0]
  def change
    add_index :assignments, :lti_consumer_key,
              unique: true,
              where: "lti_consumer_key IS NOT NULL",
              name: "index_assignments_on_lti_consumer_key"
  end
end
