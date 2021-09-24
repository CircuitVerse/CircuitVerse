module I18nData
  module FileDataProvider
    require 'fileutils'

    DATA_SEPARATOR = ";;"
    extend self

    def codes(type, language_code)
      unless data = read_from_file(cache_file_for(type, language_code))
        raise NoTranslationAvailable, "#{type}-#{language_code}"
      end
      data
    end

    def write_cache(provider)
      languages = provider.codes(:languages, 'EN').keys + ['zh_CN', 'zh_TW', 'zh_HK','bn_IN','pt_BR']
      languages.map do |language_code|
        [:languages, :countries].each do |type|
          begin
            data = provider.send(:codes, type, language_code)
            write_to_file(data, cache_file_for(type, language_code))
          rescue NoTranslationAvailable
            $stderr.puts "No translation available for #{type} #{language_code}" if $DEBUG
          rescue AccessDenied
            $stderr.puts "Access denied for #{type} #{language_code}"
          end
        end
      end
    end

    private

    def read_from_file(file)
      return nil unless File.exist?(file)
      data = {}
      File.readlines(file, :encoding => 'utf-8').each do |line|
        code, translation = line.strip.split(DATA_SEPARATOR, 2)
        data[code] = translation
      end
      data
    end

    def write_to_file(data, file)
      return if data.empty?
      FileUtils.mkdir_p File.dirname(file)
      File.open(file,'w') do |f|
        f.write data.map{|code, translation| "#{code}#{DATA_SEPARATOR}#{translation}" } * "\n"
      end
    end

    def cache_file_for(type,language_code)
      file = "#{type}-#{language_code.sub('-', '_').upcase}"
      File.join(File.dirname(__FILE__), '..', '..', 'cache', 'file_data_provider', "#{file}.txt")
    end
  end
end
