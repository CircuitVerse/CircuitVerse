# frozen_string_literal: true

require Rails.root.join('app/policies/user_policy.rb')

class UserProfileComponent < ViewComponent::Base
  attr_reader :current_user

  def initialize(profile:, current_user:)
    super
    @profile = profile
    @current_user = current_user
  end

  def policy(user)
    UserPolicy.new(user, @profile)
  end

  def show_edit_link?
    # Check permissions using the policy object
    policy(current_user).edit?
  end
end
