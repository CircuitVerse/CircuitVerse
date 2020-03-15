# Rails 4.2 call `initialize` inside `recycle!`. However Ruby 2.6 doesn't allow calling `initialize` twice.
# See for detail: https://github.com/rails/rails/issues/34790
if RUBY_VERSION.to_f >= 2.6 && Rails::VERSION::MAJOR < 5
  class ActionController::TestResponse < ActionDispatch::TestResponse
    def recycle!
      @mon_mutex_owner_object_id = nil
      @mon_mutex = nil
      initialize
    end
  end
end
