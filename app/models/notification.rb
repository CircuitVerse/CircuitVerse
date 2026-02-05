# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :notifiable, polymorphic: true
  belongs_to :group, polymorphic: true, optional: true
  belongs_to :notifier, polymorphic: true, optional: true
end
