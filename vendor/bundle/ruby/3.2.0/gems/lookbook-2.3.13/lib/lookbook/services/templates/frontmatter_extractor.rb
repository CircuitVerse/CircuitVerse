module Lookbook
  class FrontmatterExtractor < Service
    FRONTMATTER_REGEX = /\A---(.|\n)*?---/

    attr_reader :content

    def initialize(content)
      @content = content.to_s
    end

    def call
      frontmatter = extract_frontmatter(content)
      rest = strip_frontmatter(content)
      [frontmatter, rest]
    end

    protected

    def extract_frontmatter(text)
      matches = text.match(FRONTMATTER_REGEX)
      matches ? YAML.safe_load(matches[0]).deep_symbolize_keys : {}
    end

    def strip_frontmatter(text)
      text.gsub(FRONTMATTER_REGEX, "").strip
    end
  end
end
