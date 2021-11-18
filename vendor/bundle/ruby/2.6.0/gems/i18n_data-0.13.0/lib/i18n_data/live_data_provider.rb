require 'json'

module I18nData
  # fetches data online from debian git
  module LiveDataProvider
    extend self

    JSON_CODES = {
      :countries => 'data/iso_3166-1.json',
      :languages => 'data/iso_639-2.json'
    }

    TRANSLATIONS = {
      :countries => 'iso_3166-1/',
      :languages => 'iso_639-2/'
    }
    REPO = "https://salsa.debian.org/iso-codes-team/iso-codes.git"
    CLONE_DEST = "/tmp/i18n_data_iso_clone"

    def codes(type, language_code)
      ensure_checkout

      language_code = language_code.upcase
      if language_code == 'EN'
        send("english_#{type}")
      else
        translated(type, language_code)
      end
    end

    def clear_cache
      `rm -rf #{CLONE_DEST}`
      raise unless $?.success?
    end

  private

    def ensure_checkout
      unless File.exist?(CLONE_DEST)
        `git clone #{REPO} #{CLONE_DEST}`
        raise unless $?.success?
      end
    end

    def translate(type, language, to_language_code)
      translated = translations(type, to_language_code)[language]
      translated.to_s.empty? ? nil : translated
    end

    def translated(type, language_code)
      @translated ||= {}
      @translated["#{type}_#{language_code}"] ||= begin
        Hash[send("english_#{type}").map do |code, name|
          [code, translate(type, name, language_code) || name]
        end]
      end
    end

    def translations(type, language_code)
      @translations ||= {}
      @translations["#{type}_#{language_code}"] ||= begin
        code = language_code.split("_")
        code[0].downcase!
        code = code.join("_")

        url = TRANSLATIONS[type]+"#{code}.po"
        begin
          data = get(url)
        rescue Errno::ENOENT
          raise NoTranslationAvailable, "for #{type} and language code = #{code} (#{$!})"
        end

        data = data.force_encoding('utf-8') if data.respond_to?(:force_encoding) # 1.9
        data = data.split("\n")
        po_to_hash data
      end
    end

    def english_languages
      @english_languages ||= begin
        codes = {}
        json(:languages)['639-2'].each do |entry|
          name = entry['name'].to_s
          code = entry['alpha_2'].to_s.upcase
          next if code.empty? or name.empty?
          codes[code] = name
        end
        codes
      end
    end

    def english_countries
      @english_countries ||= begin
        codes = {}
        json(:countries)['3166-1'].each do |entry|
          name = (entry['common_name'] || entry['name']).to_s
          code = entry['alpha_2'].to_s.upcase
          codes[code] = name
        end
        codes
      end
    end

    def po_to_hash(data)
      names = data.select{|l| l =~ /^msgid/ }.map{|line| line.match(/^msgid "(.*?)"/)[1] }
      translations = data.select{|l| l =~ /^msgstr/ }.map{|line| line.match(/^msgstr "(.*?)"/)[1] }

      Hash[names.each_with_index.map do |name,index|
        [name, translations[index]]
      end]
    end

    def get(url)
      File.read("#{CLONE_DEST}/#{url}")
    end

    def json(type)
      JSON.parse(get(JSON_CODES[type]))
    end
  end
end
