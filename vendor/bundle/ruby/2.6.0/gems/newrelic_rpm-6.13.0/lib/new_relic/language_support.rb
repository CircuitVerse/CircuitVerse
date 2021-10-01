# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module LanguageSupport
    extend self

    @@forkable = nil
    def can_fork?
      # this is expensive to check, so we should only check once
      return @@forkable if @@forkable != nil
      @@forkable = Process.respond_to?(:fork)
    end

    def gc_profiler_usable?
      defined?(::GC::Profiler) && !jruby?
    end

    def gc_profiler_enabled?
      gc_profiler_usable? && ::GC::Profiler.enabled? && !::NewRelic::Agent.config[:disable_gc_profiler]
    end

    def object_space_usable?
      if defined?(::JRuby) && JRuby.respond_to?(:runtime)
        JRuby.runtime.is_object_space_enabled
      else
        defined?(::ObjectSpace)
      end
    end

    def jruby?
      RUBY_ENGINE == 'jruby'
    end

    def constantize(const_name)
      const_name.to_s.sub(/\A::/,'').split('::').inject(Object) do |namespace, name|
        begin
          result = namespace.const_get(name)

          # const_get looks up the inheritence chain, so if it's a class
          # in the constant make sure we found the one in our namespace.
          #
          # Can't help if the constant isn't a class...
          if result.is_a?(Module)
            expected_name = "#{namespace}::#{name}".gsub(/^Object::/, "")
            return unless expected_name == result.to_s
          end

          result
        rescue NameError
          nil
        end
      end
    end

    def bundled_gem?(gem_name)
      defined?(Bundler) && Bundler.rubygems.all_specs.map(&:name).include?(gem_name)
    rescue => e
      ::NewRelic::Agent.logger.info("Could not determine if third party #{gem_name} gem is installed", e)
      false
    end
  end
end
