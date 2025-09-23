# frozen_string_literal: true

module Solargraph
  class YardMap
    class Mapper
      module ToConstant
        extend YardMap::Helpers

        # @param code_object [YARD::CodeObjects::Base]
        def self.make code_object, closure = nil, spec = nil
          closure ||= Solargraph::Pin::Namespace.new(
            name: code_object.namespace.to_s,
            gates: [code_object.namespace.to_s],
            source: :yardoc,
          )
          Pin::Constant.new(
            location: object_location(code_object, spec),
            closure: closure,
            name: code_object.name.to_s,
            comments: code_object.docstring ? code_object.docstring.all.to_s : '',
            visibility: code_object.visibility,
            source: :yardoc
          )
        end
      end
    end
  end
end
