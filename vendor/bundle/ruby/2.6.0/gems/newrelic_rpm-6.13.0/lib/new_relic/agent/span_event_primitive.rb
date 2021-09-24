# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.
# frozen_string_literal: true

# This module builds the data structures necessary to create a Span
# event for a segment.

require 'new_relic/agent/payload_metric_mapping'
require 'new_relic/agent/distributed_tracing/distributed_trace_payload'

module NewRelic
  module Agent
    module SpanEventPrimitive
      include NewRelic::Coerce
      extend self

      # Strings for static keys of the event structure
      ELLIPSIS             = '...'
      TYPE_KEY             = 'type'
      TRACE_ID_KEY         = 'traceId'
      GUID_KEY             = 'guid'
      PARENT_ID_KEY        = 'parentId'
      GRANDPARENT_ID_KEY   = 'grandparentId'
      TRANSACTION_ID_KEY   = 'transactionId'
      SAMPLED_KEY          = 'sampled'
      PRIORITY_KEY         = 'priority'
      TIMESTAMP_KEY        = 'timestamp'
      DURATION_KEY         = 'duration'
      NAME_KEY             = 'name'
      CATEGORY_KEY         = 'category'
      HTTP_URL_KEY         = 'http.url'
      HTTP_METHOD_KEY      = 'http.method'
      HTTP_STATUS_CODE_KEY = 'http.statusCode'
      COMPONENT_KEY        = 'component'
      DB_INSTANCE_KEY      = 'db.instance'
      DB_STATEMENT_KEY     = 'db.statement'
      PEER_ADDRESS_KEY     = 'peer.address'
      PEER_HOSTNAME_KEY    = 'peer.hostname'
      SPAN_KIND_KEY        = 'span.kind'
      ENTRY_POINT_KEY      = 'nr.entryPoint'
      TRUSTED_PARENT_KEY   = "trustedParentId"
      TRACING_VENDORS_KEY  = "tracingVendors"
      TRANSACTION_NAME_KEY = 'transaction.name'

      # Strings for static values of the event structure
      EVENT_TYPE         = 'Span'
      GENERIC_CATEGORY   = 'generic'
      HTTP_CATEGORY      = 'http'
      DATASTORE_CATEGORY = 'datastore'
      CLIENT             = 'client'

      # Builds a Hash of error attributes as well as the Span ID when
      # an error is present.  Otherwise, returns nil when no error present.
      def error_attributes segment
        return if Agent.config[:high_security] || !segment.noticed_error
        segment.noticed_error.build_error_attributes
        segment.noticed_error_attributes
      end

      def for_segment segment
        intrinsics = intrinsics_for(segment)
        intrinsics[CATEGORY_KEY] = GENERIC_CATEGORY

        [intrinsics, custom_attributes(segment), agent_attributes(segment)]
      end

      def for_external_request_segment segment
        intrinsics = intrinsics_for(segment)

        intrinsics[COMPONENT_KEY]   = segment.library
        intrinsics[HTTP_METHOD_KEY] = segment.procedure
        intrinsics[HTTP_STATUS_CODE_KEY] = segment.http_status_code if segment.http_status_code
        intrinsics[CATEGORY_KEY]    = HTTP_CATEGORY
        intrinsics[SPAN_KIND_KEY]   = CLIENT

        agent_attributes = error_attributes(segment) || {}

        if allowed?(HTTP_URL_KEY)
          agent_attributes[HTTP_URL_KEY] = truncate(segment.uri)
        end

        [intrinsics, custom_attributes(segment), agent_attributes]
      end

      def for_datastore_segment segment
        intrinsics = intrinsics_for(segment)

        intrinsics[COMPONENT_KEY] = segment.product
        intrinsics[SPAN_KIND_KEY] = CLIENT
        intrinsics[CATEGORY_KEY] = DATASTORE_CATEGORY

        agent_attributes = error_attributes(segment) || {}

        if segment.database_name && allowed?(DB_INSTANCE_KEY)
          agent_attributes[DB_INSTANCE_KEY] = truncate(segment.database_name)
        end
        if segment.host && segment.port_path_or_id && allowed?(PEER_ADDRESS_KEY)
          agent_attributes[PEER_ADDRESS_KEY] = truncate("#{segment.host}:#{segment.port_path_or_id}")
        end
        if segment.host && allowed?(PEER_HOSTNAME_KEY)
          agent_attributes[PEER_HOSTNAME_KEY] = truncate(segment.host)
        end

        if segment.sql_statement && allowed?(DB_STATEMENT_KEY)
          agent_attributes[DB_STATEMENT_KEY] = truncate(segment.sql_statement.safe_sql, 2000)
        elsif segment.nosql_statement && allowed?(DB_STATEMENT_KEY)
          agent_attributes[DB_STATEMENT_KEY] = truncate(segment.nosql_statement, 2000)
        end

        [intrinsics, custom_attributes(segment), agent_attributes]
      end

      private

      def intrinsics_for segment
        intrinsics = {
          TYPE_KEY           => EVENT_TYPE,
          TRACE_ID_KEY       => segment.transaction.trace_id,
          GUID_KEY           => segment.guid,
          TRANSACTION_ID_KEY => segment.transaction.guid,
          PRIORITY_KEY       => segment.transaction.priority,
          TIMESTAMP_KEY      => milliseconds_since_epoch(segment),
          DURATION_KEY       => segment.duration,
          NAME_KEY           => segment.name
        }

        # with infinite-tracing, transactions may or may not be sampled!
        if segment.transaction.sampled?
          intrinsics[SAMPLED_KEY] = true
        end

        if segment.parent.nil?
          intrinsics[ENTRY_POINT_KEY] = true
          if txn = segment.transaction
            if header_data = txn.distributed_tracer.trace_context_header_data
              if trace_state_vendors = header_data.trace_state_vendors
                intrinsics[TRACING_VENDORS_KEY] = trace_state_vendors unless trace_state_vendors == NewRelic::EMPTY_STR
              end
            end
            if trace_state_payload = txn.distributed_tracer.trace_state_payload
              intrinsics[TRUSTED_PARENT_KEY] = trace_state_payload.id if trace_state_payload.id
            end
          end
        end

        if parent_id = parent_guid(segment)
          intrinsics[PARENT_ID_KEY] = parent_id
        end

        if segment.transaction_name
          intrinsics[TRANSACTION_NAME_KEY] = segment.transaction_name
        end

        intrinsics
      end

      def custom_attributes segment
        attributes = segment.attributes
        if attributes
          result = attributes.custom_attributes_for(NewRelic::Agent::AttributeFilter::DST_SPAN_EVENTS)
          result.freeze
        else
          NewRelic::EMPTY_HASH
        end
      end

      def agent_attributes segment
        attributes = segment.attributes
        agent_attributes = attributes.agent_attributes_for(NewRelic::Agent::AttributeFilter::DST_SPAN_EVENTS)
        error_attributes = error_attributes(segment)
        if agent_attributes || error_attributes
          agent_attributes.merge!(error_attributes) if error_attributes
          agent_attributes.freeze
        else
          NewRelic::EMPTY_HASH
        end
      end

      def parent_guid segment
        if segment.parent
          segment.parent.guid
        elsif txn = segment.transaction
          txn.distributed_tracer.parent_guid
        end
      end

      def milliseconds_since_epoch segment
        Integer(segment.start_time.to_f * 1000.0)
      end

      def truncate value, max_size=255
        value = value.to_s
        if value.bytesize > max_size
          value.byteslice(0, max_size - 2).chop! << ELLIPSIS
        else
          value
        end
      end

      def allowed? key
        NewRelic::Agent.instance.attribute_filter.allows_key?(key, AttributeFilter::DST_SPAN_EVENTS)
      end
    end
  end
end
