# frozen_string_literal: true

# This initializer handles PostgreSQL statement timeout errors gracefully
# and provides retry logic for critical operations

module StatementTimeoutHandler
  # Wraps a block with retry logic for statement timeouts
  # @param max_retries [Integer] Maximum number of retry attempts (default: 2)
  # @param wait_seconds [Float] Seconds to wait between retries (default: 0.1)
  # @yield Block to execute with timeout handling
  # @return [Object] Result of the block
  def self.with_retry(max_retries: 2, wait_seconds: 0.1)
    retries = 0
    begin
      yield
    rescue ActiveRecord::QueryCanceled,
            PG::QueryCanceled => e
      retries += 1
      if retries <= max_retries
        Rails.logger.info("Statement timeout (attempt #{retries}/#{max_retries}), retrying...")
        sleep(wait_seconds * retries) # Exponential backoff
        retry
      else
        Rails.logger.error("Statement timeout after #{max_retries} retries: #{e.message}")
        raise
      end
    end
  end
end

# Make the handler available globally
Object.include(Module.new do
  def with_statement_timeout_retry(max_retries: 2, wait_seconds: 0.1, &block)
    StatementTimeoutHandler.with_retry(max_retries: max_retries, wait_seconds: wait_seconds, &block)
  end
end)
