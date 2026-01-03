module Lookbook
  class FileSource::Component < Lookbook::BaseComponent
    attr_reader :file_path, :lines_around_highlight

    def initialize(file_path:, source: nil, highlight_lines: [], lines_around_highlight: nil,
      start_line: 1, end_line: nil, start_line_number: nil, **html_attrs)
      @file_path = file_path
      @source = source
      @highlight_lines = highlight_lines.map(&:to_i)
      @start_line = start_line
      @end_line = end_line
      @start_line_number = start_line_number
      @lines_around_highlight = lines_around_highlight
      super(**html_attrs)
    end

    def render?
      source.present?
    end

    def trimmed_source
      return unless source.present?

      from = start_line - 1
      to = end_line - 1
      source_lines[from..to].join("\n")
    end

    def source
      return @source if @source.present?

      @_source ||= File.read(file_path)
    rescue
      nil
    end

    def source_lang
      lang = Lang.guess(file_path)
      lang.present? ? lang[:name] : "plaintext"
    end

    def highlight_lines
      @highlight_lines.map { |num| num - start_line + 1 }
    end

    def source_lines
      @_source_lines ||= source&.split("\n")
    end

    def start_line
      if lines_around_highlight && @highlight_lines.any?
        start = @highlight_lines.first - lines_around_highlight
        (start > 0) ? start : 1
      else
        @start_line
      end
    end

    def start_line_number
      @start_line_number || start_line
    end

    def end_line
      line_count = source_lines.size
      if lines_around_highlight && @highlight_lines.any?
        last = @highlight_lines.last + lines_around_highlight
        (last <= line_count) ? last : line_count
      else
        (@end_line && (@end_line <= line_count)) ? @end_line : line_count
      end
    end
  end
end
