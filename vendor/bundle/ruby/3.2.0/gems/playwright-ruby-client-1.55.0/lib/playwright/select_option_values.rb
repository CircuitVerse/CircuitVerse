module Playwright
  class SelectOptionValues
    def initialize(element: nil, index: nil, value: nil, label: nil)
      params = {}

      options = []
      if value
        options.concat(convert(:value, value))
      end

      if index
        options.concat(convert(:index, index))
      end

      if label
        options.concat(convert(:label, label))
      end

      unless options.empty?
        params[:options] = options
      end

      if element
        params[:elements] = convert(:element, element)
      end

      @params = params
    end

    # @return [Hash]
    def as_params
      @params
    end

    private def convert(key, values)
      return convert(key, [values]) unless values.is_a?(Enumerable)
      return [] if values.empty?
      values.each_with_index do |value, index|
        unless value
          raise ArgumentError.new("options[#{index}]: expected object, got null")
        end
      end

      if key == :element
        values.map(&:channel)
      elsif key == :value
        values.map { |value| { valueOrLabel: value } }
      else
        values.map { |value| { key => value } }
      end
    end
  end
end
