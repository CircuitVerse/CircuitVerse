require 'uri'

module Bugsnag
  # @api private
  class Cleaner
    FILTERED = '[FILTERED]'.freeze
    RECURSION = '[RECURSION]'.freeze
    OBJECT = '[OBJECT]'.freeze
    RAISED = '[RAISED]'.freeze
    OBJECT_WITH_ID_AND_CLASS = '[OBJECT]: [Class]: %<class_name>s [ID]: %<id>d'.freeze

    ##
    # @param configuration [Configuration]
    def initialize(configuration)
      @configuration = configuration
    end

    def clean_object(object)
      @deep_filters = deep_filters?

      traverse_object(object, {}, nil)
    end

    ##
    # @param url [String]
    # @return [String]
    def clean_url(url)
      return url if @configuration.meta_data_filters.empty?

      uri = URI(url)
      return url unless uri.query

      query_params = uri.query.split('&').map { |pair| pair.split('=') }
      query_params.map! do |key, val|
        if filters_match?(key)
          "#{key}=#{FILTERED}"
        else
          "#{key}=#{val}"
        end
      end

      uri.query = query_params.join('&')
      uri.to_s
    end

    private

    ##
    # This method calculates whether we need to filter deeply or not; i.e. whether
    # we should match both with and without 'request.params'
    #
    # This is cached on the instance variable '@deep_filters' for performance
    # reasons
    #
    # @return [Boolean]
    def deep_filters?
      @configuration.meta_data_filters.any? do |filter|
        filter.is_a?(Regexp) && filter.to_s.include?("\\.".freeze)
      end
    end

    def clean_string(str)
      if defined?(str.encoding) && defined?(Encoding::UTF_8)
        if str.encoding == Encoding::UTF_8
          str.valid_encoding? ? str : str.encode('utf-16', invalid: :replace, undef: :replace).encode('utf-8')
        else
          str.encode('utf-8', invalid: :replace, undef: :replace)
        end
      elsif defined?(Iconv)
        Iconv.conv('UTF-8//IGNORE', 'UTF-8', str) || str
      else
        str
      end
    end

    def traverse_object(obj, seen, scope)
      return nil if obj.nil?

      # Protect against recursion of recursable items
      protection = if obj.is_a?(Hash) || obj.is_a?(Array) || obj.is_a?(Set)
        return seen[obj] if seen[obj]
        seen[obj] = RECURSION
      end

      value = case obj
      when Hash
        clean_hash = {}
        obj.each do |k, v|
          begin
            current_scope = [scope, k].compact.join('.')

            if filters_match_deeply?(k, current_scope)
              clean_hash[k] = FILTERED
            else
              clean_hash[k] = traverse_object(v, seen, current_scope)
            end
          # If we get an error here, we assume the key needs to be filtered
          # to avoid leaking things we shouldn't. We also remove the key itself
          # because it may cause issues later e.g. when being converted to JSON
          rescue StandardError
            clean_hash[RAISED] = FILTERED
          rescue SystemStackError
            clean_hash[RECURSION] = FILTERED
          end
        end
        clean_hash
      when Array, Set
        obj.map { |el| traverse_object(el, seen, scope) }
      when Numeric, TrueClass, FalseClass
        obj
      when String
        clean_string(obj)
      else
        # guard against objects that raise or blow the stack when stringified
        begin
          str = obj.to_s
        rescue StandardError
          str = RAISED
        rescue SystemStackError
          str = RECURSION
        end

        # avoid leaking potentially sensitive data from objects' #inspect output
        if str =~ /#<.*>/
          # Use id of the object if available
          if obj.respond_to?(:id)
            format(OBJECT_WITH_ID_AND_CLASS, class_name: obj.class, id: obj.id)
          else
            OBJECT
          end
        else
          clean_string(str)
        end
      end

      seen[obj] = value if protection
      value
    end

    ##
    # @param key [String, #to_s]
    # @return [Boolean]
    def filters_match?(key)
      str = key.to_s

      @configuration.meta_data_filters.any? do |filter|
        case filter
        when Regexp
          str.match(filter)
        else
          str.include?(filter.to_s)
        end
      end
    end

    ##
    # If someone has a Rails filter like /^stuff\.secret/, it won't match
    # "request.params.stuff.secret", so we try it both with and without the
    # "request.params." bit.
    #
    # @param key [String, #to_s]
    # @param scope [String]
    # @return [Boolean]
    def filters_match_deeply?(key, scope)
      return false unless scope_should_be_filtered?(scope)

      return true if filters_match?(key)
      return false unless @deep_filters

      return true if filters_match?(scope)

      @configuration.scopes_to_filter.any? do |scope_to_filter|
        if scope.start_with?("#{scope_to_filter}.request.params.")
          filters_match?(scope.sub("#{scope_to_filter}.request.params.", ''))
        else
          filters_match?(scope.sub("#{scope_to_filter}.", ''))
        end
      end
    end

    ##
    # Should the given scope be filtered?
    #
    # @param scope [String]
    # @return [Boolean]
    def scope_should_be_filtered?(scope)
      @configuration.scopes_to_filter.any? do |scope_to_filter|
        scope.start_with?("#{scope_to_filter}.")
      end
    end
  end
end
