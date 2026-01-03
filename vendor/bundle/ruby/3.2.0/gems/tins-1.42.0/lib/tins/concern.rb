module Tins
  module Concern
    def self.extended(base)
      base.instance_variable_set("@_dependencies", [])
    end

    def append_features(base)
      if base.instance_variable_defined?("@_dependencies")
        base.instance_variable_get("@_dependencies") << self
        false
      else
        return false if base < self
        @_dependencies.each { |dep| base.send(:include, dep) }
        super
        base.extend const_get("ClassMethods") if const_defined?("ClassMethods")
        base.class_eval(&@_included_block) if instance_variable_defined?("@_included_block")
        Thread.current[:tin_concern_args] = nil
        true
      end
    end

    def prepend_features(base)
      if base.instance_variable_defined?("@_dependencies")
        base.instance_variable_get("@_dependencies") << self
        false
      else
        return false if base < self
        @_dependencies.each { |dep| base.send(:include, dep) }
        super
        base.extend const_get("ClassMethods") if const_defined?("ClassMethods")
        base.class_eval(&@_prepended_block) if instance_variable_defined?("@_prepended_block")
        Thread.current[:tin_concern_args] = nil
        true
      end
    end

    def included(base = nil, &block)
      if base.nil?
        instance_variable_defined?(:@_included_block) and
          raise StandardError, "included block already defined"
        @_included_block = block
      else
        super
      end
    end

    def prepended(base = nil, &block)
      if base.nil?
        instance_variable_defined?(:@_prepended_block) and
          raise StandardError, "prepended block already defined"
        @_prepended_block = block
      else
        super
      end
    end

    def class_methods(&block)
      modul = const_get(:ClassMethods) if const_defined?(:ClassMethods, false)
      unless modul
        modul = Module.new
        const_set(:ClassMethods, modul)
      end
      modul.module_eval(&block)
    end
  end
end
