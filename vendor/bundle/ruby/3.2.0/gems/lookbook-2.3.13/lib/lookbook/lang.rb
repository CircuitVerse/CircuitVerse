module Lookbook
  module Lang
    class << self
      CONFIG_FILE = "config/languages.yml"
      LANGUAGES = [] # retained for backwards compatability

      def find(name)
        languages.find { |l| l[:name] == name.to_s }
      end

      def guess(path, fallback_name = nil)
        ext = File.extname(path)
        lang = languages.find { |l| l[:ext] == ext }
        lang || (find(fallback_name) if fallback_name)
      end

      protected

      def languages
        @_languages ||= [*ConfigLoader.call(CONFIG_FILE).definitions, *LANGUAGES]
      end
    end
  end
end
