# frozen_string_literal: true

class CustomMailPolicy < ApplicationPolicy
  attr_reader :user, :custom_mail

  def initialize(user, custom_mail)
    @user = user
    @custom_mail = custom_mail
  end
end
