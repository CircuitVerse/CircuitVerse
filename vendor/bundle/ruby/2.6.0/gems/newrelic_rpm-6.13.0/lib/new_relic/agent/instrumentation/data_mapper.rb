# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  named :data_mapper

  depends_on do
    defined?(::DataMapper) &&
      defined?(::DataMapper::Model) &&
      defined?(::DataMapper::Resource) &&
      defined?(::DataMapper::Collection)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing DataMapper instrumentation'
    require 'new_relic/agent/datastores/metric_helper'
  end

  executes do
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :get
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :first
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :last
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :all

    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :create
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :create!
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :update
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :update!
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :destroy
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :destroy!

    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :aggregate
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :find
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Model, :find_by_sql
  end

  executes do
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Resource, :update
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Resource, :update!
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Resource, :save
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Resource, :save!
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Resource, :destroy
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Resource, :destroy!
  end

  executes do
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :get
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :first
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :last
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :all

    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :lazy_load

    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :create
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :create!
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :update
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :update!
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :destroy
    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :destroy!

    NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Collection, :aggregate
  end

  executes do
    # Catch direct SQL calls that bypass CRUD
    if defined?(::DataMapper::Adapters::DataObjectsAdapter)
      NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Adapters::DataObjectsAdapter, :select, true
      NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Adapters::DataObjectsAdapter, :execute, true
    end
  end

  executes do
    # DM::Validations overrides Model#create, so we patch it here as well
    if defined?(::DataMapper::Validations::ClassMethods)
      NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Validations::ClassMethods, :create
    end
  end

  executes do
    # DM::Transaction calls commit() twice, so potentially shows up twice.
    if defined?(::DataMapper::Transaction)
      NewRelic::Agent::DataMapperTracing.add_tracer ::DataMapper::Transaction, :commit, true
    end
  end

  executes do
    if defined?(::DataObjects::Connection)
      ::DataObjects::Connection.class_eval do
        include ::NewRelic::Agent::Instrumentation::DataMapperInstrumentation
      end
    end
  end
end

module NewRelic
  module Agent
    module DataMapperTracing
      def self.add_tracer(clazz, method_name, operation_only = false)
        clazz.class_eval do
          if method_defined?(method_name) || private_method_defined?(method_name)
            define_method("#{method_name}_with_newrelic",
                          NewRelic::Agent::DataMapperTracing.method_body(clazz, method_name, operation_only))

            alias_method "#{method_name}_without_newrelic", method_name
            alias_method method_name, "#{method_name}_with_newrelic"
          end
        end
      end

      DATA_MAPPER = "DataMapper".freeze
      PASSWORD_REGEX = /&password=.*?(&|$)/
      AMPERSAND = '&'.freeze
      PASSWORD_PARAM = '&password='.freeze

      def self.method_body(clazz, method_name, operation_only)
        use_model_name   = NewRelic::Helper.instance_methods_include?(clazz, :model)
        metric_operation = method_name.to_s.gsub(/[!?]/, "")

        Proc.new do |*args, &blk|
          begin
            if operation_only
              # Used by direct SQL, like ::DataMapper::Adapters::DataObjectsAdapter#select
              name = nil
            elsif use_model_name
              # Used by ::DataMapper::Collection to get contained model name
              name = self.model.name
            elsif self.is_a?(Class)
              # Used by class-style access, like Model.first()
              name = self.name
            else
              # Used by instance-style access, like model.update(attr: "new")
              name = self.class.name
            end

            segment = NewRelic::Agent::Tracer.start_datastore_segment(
              product: DATA_MAPPER,
              operation: metric_operation,
              collection: name
            )

            begin
              NewRelic::Agent::Tracer.capture_segment_error segment do
                self.send("#{method_name}_without_newrelic", *args, &blk)
              end
            rescue ::DataObjects::ConnectionError => e
              raise
            rescue ::DataObjects::SQLError => e
              e.uri.gsub!(PASSWORD_REGEX, AMPERSAND) if e.uri.include?(PASSWORD_PARAM)

              strategy = NewRelic::Agent::Database.record_sql_method(:slow_sql)
              case strategy
              when :obfuscated
                adapter_name = if self.respond_to?(:options)
                    self.options[:adapter]
                  else
                    if self.repository.adapter.respond_to?(:options)
                      self.repository.adapter.options[:adapter]
                    else
                      # DataMapper < 0.10.0
                      self.repository.adapter.uri.scheme
                    end
                  end
                statement = NewRelic::Agent::Database::Statement.new(e.query, :adapter => adapter_name)
                obfuscated_sql = NewRelic::Agent::Database.obfuscate_sql(statement)
                e.instance_variable_set(:@query, obfuscated_sql)
              when :off
                e.instance_variable_set(:@query, nil)
              end

              raise
            ensure
              segment.finish if segment
            end
          end
        end
      end
    end

    module Instrumentation
      module DataMapperInstrumentation
        # Unlike in AR, log is called in DM after the query actually ran,
        # complete with metrics.  Since DO has already calculated the
        # duration, there's nothing more to measure, so just record and log.
        #
        # We rely on the assumption that all possible entry points have been
        # hooked with tracers, ensuring that notice_sql attaches this SQL to
        # the proper call scope.
        def log(msg) #THREAD_LOCAL_ACCESS
          state = NewRelic::Agent::Tracer.state
          return unless state.is_execution_traced?

          txn = state.current_transaction

          if txn && txn.current_segment.respond_to?(:notice_sql)
            txn.current_segment.notice_sql msg.query
          end
        ensure
          super
        end
      end
    end
  end
end
