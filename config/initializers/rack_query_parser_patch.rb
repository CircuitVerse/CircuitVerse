# frozen_string_literal: true

require "rack/query_parser"

module RackQueryParserPatch
  def _normalize_params(params, name, v, depth)
    name = name.encode(Encoding::UTF_8, invalid: :replace, undef: :replace) if name.is_a?(String) && !name.encoding.ascii_compatible?
    v = v.encode(Encoding::UTF_8, invalid: :replace, undef: :replace) if v.is_a?(String) && !v.encoding.ascii_compatible?
    super(params, name, v, depth)
  end
end

Rack::QueryParser.prepend(RackQueryParserPatch)
