# frozen_string_literal: true

class ProjectDatumValidator
  attr_reader :error_message

  def initialize(data)
    @data = data
    @error_message = nil
  end

  def valid?
    parsed = parse_json
    return false unless parsed
    return false unless required_keys_present?(parsed)

    true
  end

  private

  def parse_json
    return @data if @data.is_a?(Hash)

    JSON.parse(@data)
  rescue JSON::ParserError
    @error_message = "Invalid JSON format"
    nil
  end

  def required_keys_present?(parsed)
    unless parsed.key?("scopes")
      @error_message = "Missing required key: scopes"
      return false
    end

    true
  end
end
