module Lookbook
  module InspectableEntity
    extend ActiveSupport::Concern

    included do
      # @!group Source

      # Scenario method source code
      #
      # @return [String] The source code0
      def source
        source_code = if custom_source?
          File.read(source_file_path)
        else
          src = CodeIndenter.call(code_object.source)
          begin
            send(:format_source, src)
          rescue NoMethodError
            src
          end
        end

        source_code.strip_heredoc.strip
      end

      # Source code language info.
      #
      # Returns a Hash with `name`, `ext` & `label` entries.
      #
      # @example :ruby
      #   source_lang_name = entity.lang[:name]
      #
      # @return [Hash] Language info hash
      def source_lang
        custom_source? ? Lang.guess(source_file_path, :ruby) : Lang.find(:ruby)
      end

      # @!endgroup

      # @api private
      def custom_source?
        source_file_path.present?
      end

      protected

      attr_reader :code_object

      def source_file_path
        @_source_path ||= if code_object.has_tag?(:source)
          source_path = code_object.tag(:source).value
          unless source_path.present? && File.exist?(source_path)
            raise Lookbook::Error, "Could not find source file '#{source_path}'"
          end
          source_path
        end
      end
    end
  end
end
