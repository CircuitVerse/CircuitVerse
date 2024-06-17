# frozen_string_literal: true

#
# == Schema Information
#
# Table name: noticed_notifications
#
#  id                        :bigint           not null, primary key
#  recipient_type            :string
#  recipient_id              :bigint
#  type                      :string
#  params                    :jsonb
#  read_at                   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_noticed_notifications_on_read_at                    (read_at)
#  index_noticed_notifications_on_recipient  (recipient_type,recipient_id)
#

class NoticedNotification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true
end
