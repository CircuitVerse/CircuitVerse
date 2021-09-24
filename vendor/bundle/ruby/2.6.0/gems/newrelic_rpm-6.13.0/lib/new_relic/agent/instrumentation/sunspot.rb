# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  @name = :sunspot

  depends_on do
    defined?(::Sunspot)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing Rails Sunspot instrumentation'
  end

  executes do
    ::Sunspot.module_eval do
      class << self
        %w(index index!).each do |method|
          add_method_tracer method, 'SolrClient/Sunspot/index'
        end
        add_method_tracer :commit, 'SolrClient/Sunspot/commit'

        %w[search more_like_this].each do |method|
          add_method_tracer method, 'SolrClient/Sunspot/query'
        end
        %w[remove remove! remove_by_id remove_by_id! remove_all remove_all!].each do |method|
          add_method_tracer method, 'SolrClient/Sunspot/delete'
        end
      end
    end
  end
end
