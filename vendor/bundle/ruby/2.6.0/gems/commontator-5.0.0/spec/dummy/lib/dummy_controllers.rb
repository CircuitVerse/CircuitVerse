module DummyControllers
  def current_user
    @current_user ||= DummyUser.first_or_create!
    @current_user.can_read = true
    @current_user.can_edit = true
    @current_user
  end
end

ActionController::Base.send :include, DummyControllers
