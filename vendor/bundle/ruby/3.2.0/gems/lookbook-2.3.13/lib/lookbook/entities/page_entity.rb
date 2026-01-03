module Lookbook
  # Represents a documentation page
  #
  # @api public
  class PageEntity < Entity
    include LocatableEntity
    include NavigableEntity

    # @api private
    attr_reader :content

    # @api private
    attr_reader :sections

    # @api private
    def initialize(file_path)
      @file_path = Pathname(file_path)
      @base_directories = Engine.page_paths
      @lookup_path = PathUtils.to_lookup_path(relative_file_path)
      @frontmatter, @content = FrontmatterExtractor.call(file_contents)
      @priority_prefixes = true
      @sections = []
    end

    # @!group Identity

    # Page title, as defined in frontmatter.
    # Defaults to the page `label` if not provided.
    #
    # @return [String] The title
    def title
      @_title ||= fetch_config(:title, label)
    end

    # @!endgroup

    # @!group Frontmatter

    # Merged data hash. Combines `data` set in frontmatter
    # with any global default values.
    #
    # @return [Hash] The resolved data hash
    def data
      return @_data if @_data

      config_data = fetch_config(:data, {})
      @_data ||= config_data.is_a?(Hash) ? Store.new(config_data) : config_data
    end

    # @!endgroup

    # @!group Predicates

    # Whether the page is the default landing page.
    #
    # Set via the `landing` frontmatter property.
    #
    # @return [Boolean]
    def landing?
      @_landing ||= fetch_config(:landing, false)
    end

    # Whether the page content should be rendered
    # with the Markdown renderer.
    #
    # Set via the `markdown` frontmatter property.
    #
    # @return [Boolean]
    def markdown?
      @_markdown ||= fetch_config(:markdown) { file_path.to_s.match?(/(.*)\.md\.(.*)$/) }
    end

    # Whether the page header will be shown.
    #
    # Set via the `header` frontmatter property.
    #
    # @return [Boolean]
    def header?
      @_header ||= fetch_config(:header, true)
    end

    # Whether the page footer will be shown.
    #
    # Set via the `footer` frontmatter property.
    #
    # @return [Boolean]
    def footer?
      @_footer ||= fetch_config(:footer, true)
    end

    # @!endgroup

    # @!group URLs

    # The docs URL path for this page.
    #
    # @return [String] URL path
    def docs_path
      lookbook_page_path(lookup_path)
    end

    alias_method :url_path, :docs_path

    # @!endgroup

    # @api private
    def search_terms
      lookup_path.split("/") << label
    end

    # @api private
    def add_section(section)
      @sections << section
      @sections.sort_by! { |section| [section.priority, section.label] }
    end

    # @api private
    def method_missing(method_name, *args, &block)
      method_name.to_s.end_with?("=") ? super : frontmatter.fetch(method_name, nil)
    end

    # @api private
    def respond_to_missing?(method_name, include_private = false)
      frontmatter.key?(method_name) || super
    end

    protected

    def fetch_config(key, fallback = nil, &block)
      value = frontmatter[key]
      Utils.value_or_fallback(value, fallback, &block)
    end

    def file_contents
      @_file_contents ||= File.read(file_path)
    end

    def frontmatter
      @_merged_frontmatter ||= Lookbook.config.page_options.deep_merge(@frontmatter.to_h).deep_symbolize_keys
    end
  end
end
