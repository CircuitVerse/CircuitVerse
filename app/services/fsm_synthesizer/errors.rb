# frozen_string_literal: true

module FsmSynthesizer
  class BaseError < StandardError; end
  class ValidationError < BaseError; end
  class SchemaError < BaseError; end
  class EncodingError < BaseError; end
  class GenerationError < BaseError; end
end
