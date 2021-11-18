# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

require 'new_relic/agent/database'

module NewRelic
  module Instrumentation
    module ActsAsSolrInstrumentation
      module ParserMethodsInstrumentation

        if RUBY_VERSION < "2.7.0"
          def parse_query_with_newrelic(*args)
            self.class.trace_execution_scoped(["SolrClient/ActsAsSolr/query"]) do
              begin
                parse_query_without_newrelic(*args)
              ensure
                return unless txn = ::NewRelic::Agent::Tracer.current_transaction
                txn.current_segment.params[:statement] = ::NewRelic::Agent::Database.truncate_query(args.first.inspect) rescue nil
              end
            end
          end
  
        else
          def parse_query_with_newrelic(*args, **kwargs)
            self.class.trace_execution_scoped(["SolrClient/ActsAsSolr/query"]) do
              begin
                parse_query_without_newrelic(*args, **kwargs)
              ensure
                return unless txn = ::NewRelic::Agent::Tracer.current_transaction
                txn.current_segment.params[:statement] = ::NewRelic::Agent::Database.truncate_query(args.first.inspect) rescue nil
              end
            end
          end
  
        end
      end
    end
  end
end

DependencyDetection.defer do
  @name = :acts_as_solr

  depends_on do
    defined?(ActsAsSolr)
  end

  depends_on do
    defined?(ActsAsSolr::ParserMethods)
  end

  depends_on do
    defined?(ActsAsSolr::ClassMethods)
  end

  depends_on do
    defined?(ActsAsSolr::CommonMethods)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing ActsAsSolr instrumentation'
  end

  executes do
    ActsAsSolr::ParserMethods.module_eval do
      include NewRelic::Instrumentation::ActsAsSolrInstrumentation::ParserMethodsInstrumentation
      alias :parse_query_without_newrelic :parse_query
      alias :parse_query :parse_query_with_newrelic
    end
  end

  executes do
    ActsAsSolr::ClassMethods.module_eval do
      %w[find_by_solr find_id_by_solr multi_solr_search count_by_solr].each do |method|
        add_method_tracer method, 'SolrClient/ActsAsSolr/query'
      end
      add_method_tracer :rebuild_solr_index, 'SolrClient/ActsAsSolr/index'
    end
  end

  executes do
    ActsAsSolr::CommonMethods.module_eval do
      add_method_tracer :solr_add, 'SolrClient/ActsAsSolr/add'
      add_method_tracer :solr_delete, 'SolrClient/ActsAsSolr/delete'
      add_method_tracer :solr_commit, 'SolrClient/ActsAsSolr/commit'
      add_method_tracer :solr_optimize, 'SolrClient/ActsAsSolr/optimize'
    end
  end
end
