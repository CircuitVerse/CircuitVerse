# frozen_string_literal: true

class CustomMailPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [CustomMail]
  attr_reader :custom_mail

  # @param [User] user
  # @param [CustomMail] custom_mail
  def initialize(user, custom_mail)
    @user = user
    @custom_mail = custom_mail
  end
end
