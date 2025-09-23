module Lookbook
  # Base entity class
  #
  # @api public
  class Entity
    include Comparable
    send(:include, Lookbook::Engine.routes.url_helpers) # YARD parsing workaround: https://github.com/lsegal/yard/issues/546

    # @api private
    def initialize(lookup_path = nil)
      @lookup_path = lookup_path
    end

    # @!group Identity

    # Human-readable unique ID for the entity
    #
    # @return [String] The ID
    def id
      Utils.id(fetch_config(:id) { lookup_path.tr("/", "-") })
    end

    # Parameter-safe entity name.
    #
    # @return [String] The name
    def name
      @_name ||= Utils.name(File.basename(@lookup_path))
    end

    # Titlized name for use in navigation etc.
    #
    # Can be customized using the `@label` tag where supported.
    #
    # @return [String] The label
    def label
      @_label ||= fetch_config(:label) { name.titleize }
    end

    # Entity type identifier
    #
    # @return [Symbol] The entity type
    def type
      @_type ||= self.class.name.gsub("Entity", "").demodulize.underscore.downcase.to_sym
    end

    # @!endgroup

    # @!group Paths

    # Canonical reference path.
    #
    # Used for generating URL paths and looking up entities.
    #
    # @return [String] The lookup path
    def lookup_path
      return @_lookup_path if @_lookup_path

      directory = fetch_config(:logical_path) do
        dir = File.dirname(@lookup_path)
        dir if !dir.start_with?(".")
      end
      @_lookup_path ||= PathUtils.strip_slashes(PathUtils.to_path(directory, name))
    end

    alias_method :path, :lookup_path
    deprecate path: :lookup_path, deprecator: Deprecation

    def search_terms
      @_search_terms ||= lookup_path.split("/").map(&:titleize)
    end

    # @!endgroup

    def <=>(other)
      label <=> other.label
    end

    protected

    def fetch_config(key, fallback = nil, &block)
      Utils.value_or_fallback(nil, fallback, &block)
    end
  end
end
