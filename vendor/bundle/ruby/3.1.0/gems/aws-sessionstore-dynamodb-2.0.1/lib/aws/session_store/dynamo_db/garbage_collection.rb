require 'aws-sdk-dynamodb'

module Aws::SessionStore::DynamoDB
  # Collects and deletes unwanted sessions based on
  # their creation and update dates.
  module GarbageCollection
    module_function

    # Scans DynamoDB session table to find
    # sessions that match the max age and max stale period
    # requirements. it then deletes all of the found sessions.
    def collect_garbage(options = {})
      config = load_config(options)
      last_key = eliminate_unwanted_sessions(config)
      while !last_key.empty?
        last_key = eliminate_unwanted_sessions(config, last_key)
      end
    end

    # Loads configuration options.
    # @option (see Configuration#initialize)
    # @api private
    def load_config(options = {})
      Aws::SessionStore::DynamoDB::Configuration.new(options)
    end

    # Sets scan filter attributes based on attributes specified.
    # @api private
    def scan_filter(config)
      hash = {}
      hash['created_at'] = oldest_date(config.max_age) if config.max_age
      hash['updated_at'] = oldest_date(config.max_stale) if config.max_stale
      { :scan_filter => hash }
    end

    # Scans and deletes batch.
    # @api private
    def eliminate_unwanted_sessions(config, last_key = nil)
      scan_result = scan(config, last_key)
      batch_delete(config, scan_result[:items])
      scan_result[:last_evaluated_key] || {}
    end

    # Scans the table for sessions matching the max age and
    # max stale time specified.
    # @api private
    def scan(config, last_item = nil)
      options = scan_opts(config)
      options = options.merge(start_key(last_item)) if last_item
      config.dynamo_db_client.scan(options)
    end

    # Deletes the batch gotten from the scan result.
    # @api private
    def batch_delete(config, items)
      begin
        subset = items.shift(25)
        sub_batch = write(subset)
        process!(config, sub_batch)
      end until subset.empty?
    end

    # Turns array into correct format to be passed in to
    # a delete request.
    # @api private
    def write(sub_batch)
      sub_batch.inject([]) do |rqst_array, item|
        rqst_array << {:delete_request => {:key => item}}
        rqst_array
      end
    end

    # Proccesses pending request items.
    # @api private
    def process!(config, sub_batch)
      return if sub_batch.empty?
      opts = {}
      opts[:request_items] = {config.table_name => sub_batch}
      begin
        response = config.dynamo_db_client.batch_write_item(opts)
        opts[:request_items] = response[:unprocessed_items]
      end until opts[:request_items].empty?
    end

    # Provides scan options.
    # @api private
    def scan_opts(config)
      table_opts(config).merge(scan_filter(config))
    end

    # Provides table options
    # @api private
    def table_opts(config)
      {
        :table_name => config.table_name,
        :attributes_to_get => [config.table_key]
      }
    end

    # @return [Hash] Hash with specified date attributes.
    # @api private
    def oldest_date(sec)
      hash = {}
      hash[:attribute_value_list] = [:n => "#{((Time.now - sec).to_f)}"]
      hash[:comparison_operator] = 'LT'
      hash
    end

    # Provides start key.
    # @api private
    def start_key(last_item)
      { :exclusive_start_key => last_item }
    end
  end
end
