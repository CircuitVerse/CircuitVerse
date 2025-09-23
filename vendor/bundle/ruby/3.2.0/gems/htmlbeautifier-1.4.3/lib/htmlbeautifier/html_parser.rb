# frozen_string_literal: true

require "htmlbeautifier/parser"

module HtmlBeautifier
  class HtmlParser < Parser
    ELEMENT_CONTENT = %r{ (?:<%.*?%>|[^>])* }mx
    HTML_VOID_ELEMENTS = %r{(?:
      area | base | br | col | command | embed | hr | img | input | keygen |
      link | meta | param | source | track | wbr
    )}mix
    HTML_BLOCK_ELEMENTS = %r{(?:
      address | article | aside | audio | blockquote | canvas | dd | details |
      dir | div | dl | dt | fieldset | figcaption | figure | footer | form |
      h1 | h2 | h3 | h4 | h5 | h6 | header | hr | li | menu | noframes |
      noscript | ol | p | pre | section | table | tbody | td | tfoot | th |
      thead | tr | ul | video
    )}mix

    MAPPINGS = [
      [%r{(<%-?=?)(.*?)(-?%>)}om,
        :embed],
      [%r{<!--\[.*?\]>}om,
        :open_ie_cc],
      [%r{<!\[.*?\]-->}om,
        :close_ie_cc],
      [%r{<!--.*?-->}om,
        :standalone_element],
      [%r{<!.*?>}om,
        :standalone_element],
      [%r{(<script#{ELEMENT_CONTENT}>)(.*?)(</script>)}omi,
        :foreign_block],
      [%r{(<style#{ELEMENT_CONTENT}>)(.*?)(</style>)}omi,
        :foreign_block],
      [%r{(<pre#{ELEMENT_CONTENT}>)(.*?)(</pre>)}omi,
        :preformatted_block],
      [%r{(<textarea#{ELEMENT_CONTENT}>)(.*?)(</textarea>)}omi,
        :preformatted_block],
      [%r{<#{HTML_VOID_ELEMENTS}(?: #{ELEMENT_CONTENT})?/?>}om,
        :standalone_element],
      [%r{</#{HTML_BLOCK_ELEMENTS}>}om,
        :close_block_element],
      [%r{<#{HTML_BLOCK_ELEMENTS}(?: #{ELEMENT_CONTENT})?>}om,
        :open_block_element],
      [%r{</#{ELEMENT_CONTENT}>}om,
        :close_element],
      [%r{<#{ELEMENT_CONTENT}[^/]>}om,
        :open_element],
      [%r{<[\w\-]+(?: #{ELEMENT_CONTENT})?/>}om,
        :standalone_element],
      [%r{(\s*\r?\n\s*)+}om,
        :new_lines],
      [%r{[^<\n]+},
        :text]
    ].freeze

    def initialize
      super do |p|
        MAPPINGS.each do |regexp, method|
          p.map regexp, method
        end
      end
    end
  end
end
