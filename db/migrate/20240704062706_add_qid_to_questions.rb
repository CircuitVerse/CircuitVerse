# frozen_string_literal: true

class AddQidToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :qid, :string
  end
end
