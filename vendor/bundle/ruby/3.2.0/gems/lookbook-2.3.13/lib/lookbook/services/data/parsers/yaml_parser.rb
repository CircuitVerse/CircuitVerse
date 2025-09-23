module Lookbook
  class YamlParser < DataParser
    def parse(input)
      YAML.safe_load(input.to_s)
    end
  end
end
