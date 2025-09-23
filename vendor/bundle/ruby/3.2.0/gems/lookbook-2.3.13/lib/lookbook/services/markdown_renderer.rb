require "redcarpet"

module Lookbook
  class MarkdownRenderer < Service
    attr_reader :text, :extensions, :options

    # In Lookbook config, `markdown_options` are actually Redcarpet `extensions` so we store them as `@extensions`
    def initialize(text, extensions = {}, options = {})
      @text = text
      @extensions = Lookbook.config.markdown_options.merge(extensions.to_h)
      @options = default_options.merge(options.to_h)
    end

    def call
      clean_text = ActionViewAnnotationsStripper.call(text)
      md = Redcarpet::Markdown.new(LookbookMarkdownRenderer.new(default_options), extensions)
      md.render(clean_text).html_safe
    end

    class LookbookMarkdownRenderer < Redcarpet::Render::HTML
      def block_code(code, language = "ruby")
        line_numbers = language.to_s.end_with? "-numbered"
        ApplicationController.render(Lookbook::Code::Component.new(source: code,
          language: language.to_s.chomp("-numbered"),
          line_numbers: line_numbers), layout: nil)
      end

      def postprocess(full_document)
        full_document&.gsub!("<p><lookbook", "<lookbook")
        full_document&.gsub!("</lookbook-embed></p>", "</lookbook-embed>")
        full_document
      end
    end

    def default_options
      {
        with_toc_data: true
      }
    end
  end
end
