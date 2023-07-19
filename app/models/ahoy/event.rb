# frozen_string_literal: true

#
# == Schema Information
#
# Table name: ahoy_events
#
#  id         :bigint           not null, primary key
#  visit_id   :bigint
#  user_id    :bigint
#  name       :string
#  properties :json
#  time       :datetime
#
# Indexes
#
#  index_ahoy_events_on_name_and_time (name,time)
#  index_ahoy_events_on_user_id      (user_id)
#  index_ahoy_events_on_visit_id     (visit_id)

class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods
  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true
end
