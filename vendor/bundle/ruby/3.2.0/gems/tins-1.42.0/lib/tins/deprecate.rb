module Tins
  module Deprecate
    def deprecate(method:, new_method: nil, message: nil)
      message ||= '[DEPRECATION] `%{method}` is deprecated. Please use `%{new_method}` instead.'
      message = message % { method: method, new_method: new_method }
      m = Module.new do
        define_method(method) do |*a, **kw, &b|
          warn message
          super(*a, **kw, &b)
        end
      end
      prepend m
    end
  end
end
