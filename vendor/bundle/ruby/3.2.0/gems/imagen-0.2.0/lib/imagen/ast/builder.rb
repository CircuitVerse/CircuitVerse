# frozen_string_literal: true

require 'parser'
require 'parser/builders/default'

module Imagen
  module AST
    # An AST Builder for ruby parser.
    class Builder < ::Parser::Builders::Default
      # This is a work around for parsing ruby code that with invlalid UTF-8
      # https://github.com/whitequark/parser/issues/283
      def string_value(token)
        value(token)
      end
    end
  end
end
