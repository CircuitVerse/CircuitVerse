# frozen_string_literal: true

#
# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :bigint           not null, primary key
#  visit_token      :string
#  visitor_token    :string
#  user_id          :bigint
#  ip               :string
#  user_agent       :text
#  referrer         :text
#  referring_domain :string
#  landing_page     :text
#  browser          :string
#  os               :string
#  device_type      :string
#  country          :string
#  region           :string
#  city             :string
#  utm_source       :string
#  utm_medium       :string
#  utm_term         :string
#  utm_content      :string
#  utm_campaign     :string
#  app_version      :string
#  os_version       :string
#  platform         :string
#  started_at       :datetime
#
# Indexes
#
#  index_ahoy_visits_on_user_id       (user_id)
#  index_ahoy_visits_on_visit_token   (visit_token) UNIQUE
#

class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event", dependent: :destroy
  belongs_to :user, optional: true
end
