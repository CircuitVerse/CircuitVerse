class DummyUser < ActiveRecord::Base
  acts_as_commontator

  attr_accessor :is_admin, :can_edit, :can_read

  def email
    "dummy_user#{id}@example.com"
  end

  def name
    "Dummy User ##{id}"
  end
end

