module ApplicationHelper
  @@user = nil

  def current_user
    @@user
  end

  def sign_in(user)
    @@user = user
  end

  def sign_out
    @@user = nil
  end
end

