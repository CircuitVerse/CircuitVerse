# frozen_string_literal: true

class TestSet < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :forked_testset, class_name: "TestSet", optional: true
  belongs_to :assignment, optional: true

  validates :title, length: { minimum: 1 }

  def fork(user)
    forked_testset = dup
    forked_testset.update(author_id: user.id, forked_testset_id: id)
    forked_testset
  end
end
