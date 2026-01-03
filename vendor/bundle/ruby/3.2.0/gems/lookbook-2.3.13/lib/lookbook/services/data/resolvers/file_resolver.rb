module Lookbook
  class FileResolver < DataResolver
    MATCHER = /(\S+\.(json|yml))$/
    MATCH_INDEX = 1

    protected

    def resolve(input)
      path = resolve_path(input, base_dir)
      content = read_file(path)

      case path.extname
      when ".json"
        JsonParser.call(content)
      when ".yml"
        YamlParser.call(content)
      end
    end

    def read_file(path)
      File.exist?(path.to_s) ? File.read(path) : raise_error("The data file at '#{path}' could not be found")
    end

    def resolve_path(path, base_dir)
      Pathname(path.start_with?(".") ? File.expand_path(path, base_dir) : Rails.root.join(path))
    end
  end
end
