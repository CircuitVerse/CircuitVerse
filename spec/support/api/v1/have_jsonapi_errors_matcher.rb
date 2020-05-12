RSpec::Matchers.define :have_jsonapi_errors do |expected|
  match do |actual|
    parsed_actual = JSON.parse(actual)
    errors = parsed_actual['errors']
    return false if errors.empty?
    errors.any? do |error|
      error.key?('status') &&
      error.key?('title') &&
      error.key?('detail')
    end
  end
end
