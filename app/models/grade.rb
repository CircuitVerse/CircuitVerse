# frozen_string_literal: true

class Grade < ApplicationRecord
  belongs_to :project
  belongs_to :grader, class_name: "User", foreign_key: :user_id
  belongs_to :assignment
end
