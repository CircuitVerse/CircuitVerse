# frozen_string_literal: true

module ERBLint
  # Stores all linters available to the application.
  module LinterRegistry
    CUSTOM_LINTERS_DIR = '.erb-linters'
    @linters = []

    class << self
      attr_reader :linters

      def included(linter_class)
        @linters << linter_class
      end

      def find_by_name(name)
        linters.detect { |linter| linter.simple_name == name }
      end

      def load_custom_linters(directory = CUSTOM_LINTERS_DIR)
        ruby_files = Dir.glob(File.expand_path(File.join(directory, '**', '*.rb')))
        ruby_files.each { |file| require file }
      end
    end
  end
end
