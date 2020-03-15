# frozen_string_literal: true

module ERBLint
  # Loads file from disk
  class FileLoader
    attr_reader :base_path

    def initialize(base_path)
      @base_path = base_path
    end

    def yaml(filename)
      YAML.safe_load(read_content(filename), [Regexp, Symbol], [], false, filename) || {}
    end

    private

    def read_content(filename)
      path = File.expand_path(filename, base_path)
      File.read(path)
    end
  end
end
