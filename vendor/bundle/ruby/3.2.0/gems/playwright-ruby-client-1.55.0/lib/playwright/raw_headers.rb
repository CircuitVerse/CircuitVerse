module Playwright
  class RawHeaders
    def initialize(headers_array)
      h_array = []
      h_map = {}
      headers_array.each do |header|
        name = header['name']
        key = name.downcase
        value = header['value']

        h_array << [name, value]
        h_map[key] ||= []
        h_map[key] << value
      end

      @headers_array = h_array
      @headers_map = h_map
    end

    # @return [String|nil]
    def get(name)
      key = name.downcase
      values = @headers_map[key]
      if values
        join(key, values)
      else
        nil
      end
    end

    # @return [Array<String>]
    def get_all(name)
      values = @headers_map[name.downcase]
      if values
        values.dup
      else
        []
      end
    end

    def headers
      @headers_map.map do |key, values|
        [key, join(key, values)]
      end.to_h
    end

    def headers_array
      @headers_array.map do |name, value|
        { name: name, value: value }
      end
    end

    private def join(key, values)
      if key == 'set-cookie'
        values.join("\n")
      else
        values.join(", ")
      end
    end
  end
end
