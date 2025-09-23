# frozen_string_literal: true

module Solargraph
  class YardMap
    class Mapper
      module ToNamespace
        extend YardMap::Helpers

        # @param code_object [YARD::CodeObjects::NamespaceObject]
        def self.make code_object, spec, closure = nil
          closure ||= Solargraph::Pin::Namespace.new(
            name: code_object.namespace.to_s,
            closure: Pin::ROOT_PIN,
            gates: [code_object.namespace.to_s],
            source: :yardoc,
          )
          Pin::Namespace.new(
            location: object_location(code_object, spec),
            name: code_object.name.to_s,
            comments: code_object.docstring ? code_object.docstring.all.to_s : '',
            type: code_object.is_a?(YARD::CodeObjects::ClassObject) ? :class : :module,
            visibility: code_object.visibility,
            closure: closure,
            source: :yardoc,
          )
        end
      end
    end
  end
end
