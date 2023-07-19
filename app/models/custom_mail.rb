# frozen_string_literal: true

#
# == Schema Information
#
# Table name: custom_mails
#
#  id            :bigint           not null, primary key
#  user_id       :bigint
#  subject       :string
#  content       :text
#  sent          :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_custom_mails_on_user_id  (user_id)

class CustomMail < ApplicationRecord
  belongs_to :sender, class_name: "User", foreign_key: :user_id
end
