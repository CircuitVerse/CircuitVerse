# frozen_string_literal: true

# Nested unique header generation
require "middleman-core/renderers/redcarpet"

class NestingUniqueHeadCounter < Middleman::Renderers::MiddlemanRedcarpetHTML
  def initialize
    super
    @@headers_history = {} unless defined?(@@headers_history)
  end

  def header(text, header_level)
    friendly_text = text.gsub(/<[^>]*>/, "").parameterize
    @@headers_history[header_level] = text.parameterize

    if header_level > 1
      (header_level - 1).downto(1).each do |i|
        friendly_text.prepend("#{@@headers_history[i]}-") if @@headers_history.key?(i)
      end
    end

    "<h#{header_level} id='#{friendly_text}'>#{text}</h#{header_level}>"
  end
end
