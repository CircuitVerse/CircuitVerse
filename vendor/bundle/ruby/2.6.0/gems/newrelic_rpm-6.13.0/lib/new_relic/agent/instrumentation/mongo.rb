# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

DependencyDetection.defer do
  named :mongo

  depends_on do
    defined?(::Mongo)
  end

  depends_on do
    require 'new_relic/agent/datastores/mongo'
    if NewRelic::Agent::Datastores::Mongo.is_unsupported_2x?
      NewRelic::Agent.logger.log_once(:info, :mongo2, 'Detected unsupported Mongo 2, upgrade your Mongo Driver to 2.1 or newer for instrumentation')
    end
    NewRelic::Agent::Datastores::Mongo.is_supported_version?
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Mongo instrumentation'
    if NewRelic::Agent::Datastores::Mongo.is_monitoring_enabled?
      install_mongo_command_subscriber
    else
      install_mongo_instrumentation
    end
  end

  def install_mongo_command_subscriber
    require 'new_relic/agent/instrumentation/mongodb_command_subscriber'
    Mongo::Monitoring::Global.subscribe(
      Mongo::Monitoring::COMMAND,
      NewRelic::Agent::Instrumentation::MongodbCommandSubscriber.new
    )
  end

  def install_mongo_instrumentation
    require 'new_relic/agent/datastores/mongo/metric_translator'
    require 'new_relic/agent/datastores/mongo/statement_formatter'

    hook_instrument_methods
    instrument_save
    instrument_ensure_index
  end

  def hook_instrument_methods
    hook_instrument_method(::Mongo::Collection)
    hook_instrument_method(::Mongo::Connection)
    hook_instrument_method(::Mongo::Cursor)
    hook_instrument_method(::Mongo::CollectionWriter) if defined?(::Mongo::CollectionWriter)
  end

  def hook_instrument_method(target_class)
    target_class.class_eval do
      include NewRelic::Agent::MethodTracer

      # It's key that this method eats all exceptions, as it rests between the
      # Mongo operation the user called and us returning them the data. Be safe!
      def new_relic_notice_statement(segment, payload, name)
        statement = NewRelic::Agent::Datastores::Mongo::StatementFormatter.format(payload, name)
        if statement
          segment.notice_nosql_statement statement
        end
      rescue => e
        NewRelic::Agent.logger.debug("Exception during Mongo statement gathering", e)
      end

      def new_relic_default_payload
        { :collection => self.name, :database => self.db.name }
      end

      def new_relic_start_segment name, payload
        product = NewRelic::Agent::Datastores::Mongo::MetricTranslator::MONGO_PRODUCT_NAME
        op_and_col = NewRelic::Agent::Datastores::Mongo::MetricTranslator.operation_and_collection_for name, payload
        if op_and_col
          operation, collection = op_and_col
          NewRelic::Agent::Tracer.start_datastore_segment(
            product: product,
            operation: operation,
            collection: collection
          )
        end
      end

      def instrument_with_new_relic_trace(name, payload = {}, &block)
        segment = new_relic_start_segment name, payload

        begin
          result = NewRelic::Agent.disable_all_tracing do
            NewRelic::Agent::Tracer.capture_segment_error segment do
              instrument_without_new_relic_trace(name, payload, &block)
            end
          end

          new_relic_notice_statement(segment, payload, name) if segment
          result
        ensure
          segment.finish if segment
        end
      end

      alias_method :instrument_without_new_relic_trace, :instrument
      alias_method :instrument, :instrument_with_new_relic_trace
    end
  end

  def instrument_save
    ::Mongo::Collection.class_eval do
      def save_with_new_relic_trace(doc, opts = {}, &block)
        segment = new_relic_start_segment :save, new_relic_default_payload

        begin
          result = NewRelic::Agent.disable_all_tracing do
            NewRelic::Agent::Tracer.capture_segment_error segment do
              save_without_new_relic_trace(doc, opts, &block)
            end
          end

          new_relic_notice_statement(segment, doc, :save) if segment
          result
        ensure
          segment.finish if segment
        end
      end

      alias_method :save_without_new_relic_trace, :save
      alias_method :save, :save_with_new_relic_trace
    end
  end

  def instrument_ensure_index
    ::Mongo::Collection.class_eval do
      def ensure_index_with_new_relic_trace(spec, opts = {}, &block)
        segment = new_relic_start_segment :ensureIndex, new_relic_default_payload

        begin
          result = NewRelic::Agent.disable_all_tracing do
            NewRelic::Agent::Tracer.capture_segment_error segment do
              ensure_index_without_new_relic_trace(spec, opts, &block)
            end
          end

          spec = case spec
                 when Array
                   Hash[spec]
                 when String, Symbol
                   { spec => 1 }
                 else
                   spec.dup
                 end

          new_relic_notice_statement(segment, spec, :ensureIndex) if segment
          result
        ensure
          segment.finish if segment
        end
      end

      alias_method :ensure_index_without_new_relic_trace, :ensure_index
      alias_method :ensure_index, :ensure_index_with_new_relic_trace
    end
  end
end
