require "yard"

module Lookbook
  class PreviewParser
    def initialize(paths, tags = nil)
      @paths = paths
      @after_parse_callbacks = []
      @after_parse_once_callbacks = []
      @parsing = Monitor.new

      define_tags(tags)
      YARD::Parser::SourceParser.after_parse_list { run_callbacks }
    end

    def parse(files = nil, &block)
      @parsing.synchronize do
        @after_parse_once_callbacks << block if block
        files_list = files ? files.select { |file| file.to_s.end_with?(".rb") } : paths

        YARD::Registry.clear
        YARD.parse(files_list)
      end
    end

    def after_parse(&block)
      @after_parse_callbacks << block
    end

    def paths
      PathUtils.normalize_paths(@paths).map { |path| "#{path}/**/*preview.rb" }
    end

    protected

    def callbacks
      [
        *@after_parse_callbacks,
        *@after_parse_once_callbacks
      ]
    end

    def run_callbacks
      callbacks.each { |cb| cb.call(YARD::Registry) }
      @after_parse_once_callbacks = []
    end

    def define_tags(tags = nil)
      tags.to_h.each do |name, tag|
        YARD::Tags::Library.define_tag(tag[:label], name, Lookbook::TagProvider)
      end
    end
  end
end
