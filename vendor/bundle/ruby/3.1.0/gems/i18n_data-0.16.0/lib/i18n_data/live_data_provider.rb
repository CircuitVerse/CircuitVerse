require 'json'
require 'simple_po_parser'

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

    def translated(type, language_code)
      @translated ||= {}

      @translated["#{type}_#{language_code}"] ||= begin
        Hash[send("alpha_codes_for_#{type}").map do |alpha2, alpha3|
          [alpha2, translate(type, alpha3, language_code) || fallback_name(type, alpha3)]
        end]
      end
    end

    def translate(type, alpha3, to_language_code)
      translated = translations(type, to_language_code)[alpha3]
      translated.to_s.empty? ? nil : translated
    end

    def translations(type, language_code)
      @translations ||= {}
      @translations["#{type}_#{language_code}"] ||= begin
        code = language_code.split("_")
        code[0].downcase!
        code = code.join("_")

        begin
          file_path = "#{CLONE_DEST}/#{TRANSLATIONS[type]}#{code}.po"
          data = SimplePoParser.parse(file_path)
          data = data[1..-1] # Remove the initial info block in the .po file

          # Prefer the "Common name for" blocks, but fallback to "Name for" blocks
          common_names = get_po_data(data, 'Common name for')
          fallback_names = get_po_data(data, 'Name for')

          fallback_names.merge(common_names)
        rescue Errno::ENOENT
          raise NoTranslationAvailable, "for #{type} and language code = #{code} (#{$!})"
        end
      end
    end

    def get_po_data(data, extracted_comment_string)
      # Ignores the 'fuzzy' entries
      po_entries = data.select do |t|
        t[:extracted_comment].start_with?(extracted_comment_string) && t[:flag] != 'fuzzy'
      end

      # Maps over the alpha3 country code in the 'extracted_comment'
      # Eg: "Name for GBR"
      po_entries.map.with_object({}) do |t, translations|
        alpha3 = t[:extracted_comment][-3..-1].upcase
        translation = t[:msgstr]
        translations[alpha3] = translation.is_a?(Array) ? translation.join : translation
      end
    end

    def alpha_codes_for_countries
      @alpha_codes_for_countries ||= json(:countries)['3166-1'].each_with_object({}) do |entry, codes|
        alpha2 = entry['alpha_2']&.upcase
        alpha3 = entry['alpha_3']&.upcase
        codes[alpha2] = alpha3 unless alpha2.nil?
      end
    end

    def alpha_codes_for_languages
      @alpha_codes_for_languages ||= json(:languages)['639-2'].each_with_object({}) do |entry, codes|
        alpha2 = entry['alpha_2']&.upcase
        alpha3 = entry['alpha_3']&.upcase
        codes[alpha2] = alpha3 unless alpha2.nil?
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

    def fallback_name(type, alpha3)
      send("english_#{type}")[send("alpha_codes_for_#{type}").invert[alpha3]]
    end

    def get(url)
      File.read("#{CLONE_DEST}/#{url}")
    end

    def json(type)
      JSON.parse(get(JSON_CODES[type]))
    end
  end
end
