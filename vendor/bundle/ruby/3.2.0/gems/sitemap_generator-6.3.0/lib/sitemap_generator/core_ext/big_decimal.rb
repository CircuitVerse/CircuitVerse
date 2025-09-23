require 'bigdecimal'

begin
  require 'psych'
rescue LoadError
end

require 'yaml'

# Define our own class rather than modify the global class
class SitemapGenerator::BigDecimal
  YAML_TAG = 'tag:yaml.org,2002:float'
  YAML_MAPPING = { 'Infinity' => '.Inf', '-Infinity' => '-.Inf', 'NaN' => '.NaN' }

  yaml_tag YAML_TAG

  def initialize(num)
    @value = BigDecimal(num)
  end

  def *(other)
    other * @value
  end

  def /(other)
    SitemapGenerator::BigDecimal === other ? @value / other.instance_variable_get(:@value) : @value / other
  end

  # This emits the number without any scientific notation.
  # This is better than self.to_f.to_s since it doesn't lose precision.
  #
  # Note that reconstituting YAML floats to native floats may lose precision.
  def to_yaml(opts = {})
    return super unless defined?(YAML::ENGINE) && YAML::ENGINE.syck?

    YAML.quick_emit(nil, opts) do |out|
      string = to_s
      out.scalar(YAML_TAG, YAML_MAPPING[string] || string, :plain)
    end
  end

  def encode_with(coder)
    string = to_s
    coder.represent_scalar(nil, YAML_MAPPING[string] || string)
  end

  def to_d
    self
  end

  DEFAULT_STRING_FORMAT = 'F'
  def to_s(format = DEFAULT_STRING_FORMAT)
    @value.to_s(format)
  end
end
