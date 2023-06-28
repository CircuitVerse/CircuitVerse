require 'i18n_data/version'

module I18nData

  class BaseException < StandardError
    def to_s
      "#{self.class} -- #{super}"
    end
  end

  class NoTranslationAvailable < BaseException; end
  class AccessDenied < BaseException; end
  class Unknown < BaseException; end

  class << self
    def languages(language_code='EN')
      fetch :languages, language_code do
        data_provider.codes(:languages, normal_to_region_code(language_code.to_s.upcase))
      end
    end

    def countries(language_code='EN')
      fetch :countries, language_code do
        data_provider.codes(:countries, normal_to_region_code(language_code.to_s.upcase))
      end
    end

    def country_code(name)
      recognise_code(:countries, name)
    end

    def language_code(name)
      recognise_code(:languages, name)
    end

    def data_provider
      @data_provider ||= (
        require 'i18n_data/file_data_provider'
        FileDataProvider
      )
    end

    def data_provider=(provider)
      @cache = nil
      @data_provider = provider
    end

    private

    def fetch(type, language_code)
      @cache ||= Hash.new { |h, k| h[k] = {} }
      @cache[type].fetch(language_code) { @cache[type][language_code] = yield }
    end

    # hardcode languages that do not have a default type
    # e.g. zh does not exist, but zh_CN does
    def normal_to_region_code(normal)
      {
        "ZH" => "zh_CN",
        "BN" => "bn_IN",
      }[normal] || normal
    end

    def recognise_code(type, search)
      search = search.strip

      # common languages first <-> faster in majority of cases
      language_codes = ['EN','ES','FR','DE','ZH'] | available_language_codes

      language_codes.each do |language_code|
        options =
          begin
            send(type, language_code)
          rescue NoTranslationAvailable
            next
          end

        options.each do |code, name|
          # support "Dutch" and "Dutch; Flemish", checks for inclusion first to skip the splitting
          # then check for exact match
          return code if name.include?(search) && (name == search || name.split('; ').include?(search))
        end
      end

      nil # not found
    end

    # NOTE: this is not perfect since the used provider might have more or less languages available
    # but it's better than just using the available english language codes
    def available_language_codes
      @available_languges ||= begin
        files = Dir[File.expand_path("../../cache/file_data_provider/languages-*", __FILE__)]
        files.map! { |f| f[/languages-(.*)\./, 1] }
      end
    end
  end
end
