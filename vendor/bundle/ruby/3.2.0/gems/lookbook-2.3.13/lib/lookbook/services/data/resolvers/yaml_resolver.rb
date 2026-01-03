module Lookbook
  class YamlResolver < DataResolver
    MATCHER = /((?:\{|\[)(.*?)(?:\]|\}))$/m
    MATCH_INDEX = 1

    def self.resolveable?(input)
      input.to_s.match?(MATCHER) && YamlParser.call(input, fail_silently: true)
    end

    protected

    def resolve(input)
      YamlParser.call(input)
    rescue Psych::SyntaxError => exception
      raise_error "YAML parse error (#{exception}) in '#{file}'", exception
    end
  end
end
