require 'singleton'

module Tins

  SexySingleton = Singleton.dup

  module SexySingleton
    module SingletonClassMethods
    end
  end

  class << SexySingleton
    alias __old_singleton_included__ included

    if RUBY_VERSION < "2.7"
      def included(klass)
        __old_singleton_included__(klass)
        (class << klass; self; end).class_eval do
          if Object.method_defined?(:respond_to_missing?)
            def  respond_to_missing?(name, *args)
              instance.respond_to?(name) || super
            end
          else
            def respond_to?(name, *args)
              instance.respond_to?(name) || super
            end
          end

          def method_missing(name, *args, &block)
            if instance.respond_to?(name)
              instance.__send__(name, *args, &block)
            else
              super
            end
          end
        end
        super
      end
    else
      def included(klass)
        __old_singleton_included__(klass)
        (class << klass; self; end).class_eval do
          if Object.method_defined?(:respond_to_missing?)
            def  respond_to_missing?(name, *args, **kwargs)
              instance.respond_to?(name) || super
            end
          else
            def respond_to?(name, *args, **kwargs)
              instance.respond_to?(name) || super
            end
          end

          def method_missing(name, *args, **kwargs, &block)
            if instance.respond_to?(name)
              instance.__send__(name, *args, **kwargs, &block)
            else
              super
            end
          end
        end
        super
      end
    end
  end
end
