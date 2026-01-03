module Lookbook
  class TagOptionsParser < Service
    RESOLVERS = [
      FileResolver,
      MethodResolver,
      EvalResolver,
      YamlResolver
    ]

    def initialize(input, resolver_opts = {})
      @input = input.to_s.strip
      @resolve = resolver_opts.fetch(:resolve, true)
      @resolver_opts = resolver_opts.except(:resolve)
      @fallback = resolver_opts.fetch(:fallback, {})
    end

    def call
      options_string, remaining_text = parse_input(@input)
      if resolve?
        resolved_options = resolver(options_string).call(options_string, **@resolver_opts)
        options = prepare_options(resolved_options)
        [options, remaining_text]
      else
        [options_string, remaining_text]
      end
    end

    protected

    def resolve?
      !!@resolve
    end

    def resolver(options_string)
      if options_string.present?
        handler = RESOLVERS.find { |r| r.resolveable?(options_string) }
        if handler.nil?
          Lookbook.logger.error "Invalid tag options string '#{options_string}'"
          method(:fallback_resolver)
        else
          handler
        end
      else
        method(:fallback_resolver)
      end
    end

    def fallback_resolver(*args)
      @fallback
    end

    def parse_input(input)
      matchers.each_with_object(["", input]) do |matcher, result|
        input.match(matcher) do |match_data|
          result[0] = match_data[1] # options string
          result[1] = input.gsub(matcher, "").strip # any remaining text
          return result
        end
      end
    end

    def matchers
      RESOLVERS.map { |r| r::MATCHER }
    end

    def prepare_options(options)
      options = options.is_a?(Array) ? {choices: options} : options
      options.is_a?(Hash) ? Store.new(options) : options
    end
  end
end
