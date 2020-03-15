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

    def fetch(*args)
      @cache ||= {}
      if @cache.key?(args)
        @cache[args]
      else
        @cache[args] = yield
      end
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
      common_languages = ['EN','ES','FR','DE','ZH']
      langs = (common_languages + (languages.keys - common_languages))

      langs.each do |lang|
        begin
          send(type, lang).each do |code, name|
            # supports "Dutch" and "Dutch; Flemish", checks for inclusion first -> faster
            match_found = (name.include?(search) and name.split(';').map{|s| s.strip }.include?(search))
            return code if match_found
          end
        rescue NoTranslationAvailable
        end
      end
      nil
    end
  end
end
