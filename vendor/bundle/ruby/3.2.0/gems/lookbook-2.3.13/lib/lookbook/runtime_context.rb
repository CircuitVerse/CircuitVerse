module Lookbook
  class RuntimeContext
    attr_reader :env

    def initialize(env: Rails.env)
      @env = env
    end

    def app_name
      return @_app_name if @_app_name

      app_class = Rails.application.class
      name = app_class.respond_to?(:module_parent_name) ? app_class.module_parent_name : app_class.parent_name
      @_app_name ||= name.underscore
    end

    def rails_older_than?(version)
      Gem::Version.new(Rails.version) < Gem::Version.new(version)
    end

    def rails_newer_than?(version)
      Gem::Version.new(Rails.version) >= Gem::Version.new(version)
    end

    def actioncable_installed?
      gem_installed?("actioncable")
    end

    def listen_installed?
      gem_installed?("listen")
    end

    def gem_installed?(name)
      Gem.loaded_specs.has_key?(name)
    end

    def web?
      !rake_task? && !Rails.const_defined?(:Console, false)
    end

    def rake_task?
      if defined?(Rake) && Rake.respond_to?(:application)
        File.basename($0) == "rake" || Rake.application.top_level_tasks.any?
      else
        false
      end
    end
  end
end
