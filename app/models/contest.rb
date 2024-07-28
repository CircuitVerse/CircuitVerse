# frozen_string_literal: true

class Contest < ApplicationRecord
    has_noticed_notifications model_name: "NoticedNotification"
    has_many :submissions, dependent: :destroy
end