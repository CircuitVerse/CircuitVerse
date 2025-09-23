module Playwright
  # https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_selectors.py
  define_api_implementation :SelectorsImpl do
    def initialize
      @selector_engines = []
      @contexts_for_selectors = Set.new
    end

    def register(name, contentScript: nil, path: nil, script: nil)
      source =
        if path
          File.read(path)
        elsif script
          script
        else
          raise ArgumentError.new('Either path or script parameter must be specified')
        end
      selector_engine = { name: name, source: source }
      if contentScript
        selector_engine[:contentScript] = true
      end
      @contexts_for_selectors.each do |context|
        context.send(:register_selector_engine, selector_engine)
      end
      @selector_engines << selector_engine

      nil
    end

    def set_test_id_attribute(attribute_name)
      @test_id_attribute_name = attribute_name
      ::Playwright::LocatorUtils.instance_variable_set(:@test_id_attribute_name, attribute_name)
    end

    private def update_with_selector_options(options)
      options[:selectorEngines] = @selector_engines unless @selector_engines.empty?
      options[:testIdAttributeName] = @test_id_attribute_name if @test_id_attribute_name
      options
    end

    private def contexts_for_selectors
      @contexts_for_selectors
    end
  end
end
