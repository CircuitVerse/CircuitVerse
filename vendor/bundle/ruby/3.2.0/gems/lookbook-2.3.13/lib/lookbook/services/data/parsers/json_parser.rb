module Lookbook
  class JsonParser < DataParser
    def parse(input)
      JSON.parse(input.to_s)
    end
  end
end
