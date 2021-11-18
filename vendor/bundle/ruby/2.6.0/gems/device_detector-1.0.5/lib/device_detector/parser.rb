# frozen_string_literal: true

class DeviceDetector
  class Parser
    ROOT = File.expand_path('../..', __dir__)

    REGEX_CACHE = ::DeviceDetector::MemoryCache.new({})
    private_constant :REGEX_CACHE

    def initialize(user_agent)
      @user_agent = user_agent
    end

    attr_reader :user_agent

    def name
      from_cache(['name', self.class.name, user_agent]) do
        NameExtractor.new(user_agent, regex_meta).call
      end
    end

    def full_version
      from_cache(['full_version', self.class.name, user_agent]) do
        VersionExtractor.new(user_agent, regex_meta).call
      end
    end

    private

    def regex_meta
      @regex_meta ||= matching_regex || {}
    end

    def matching_regex
      from_cache([self.class.name, user_agent]) do
        regexes.find { |r| user_agent =~ r[:regex] }
      end
    end

    def regexes
      @regexes ||= regexes_for(filepaths)
    end

    def filenames
      raise NotImplementedError
    end

    def filepaths
      filenames.map do |filename|
        [filename.to_sym, File.join(ROOT, 'regexes', filename)]
      end
    end

    def regexes_for(file_paths)
      REGEX_CACHE.get_or_set(file_paths) do
        load_regexes(file_paths).flat_map { |path, regex| parse_regexes(path, regex) }
      end
    end

    def load_regexes(file_paths)
      file_paths.map { |path, full_path| [path, symbolize_keys!(YAML.load_file(full_path))] }
    end

    def symbolize_keys!(object)
      case object
      when Array
        object.map! { |v| symbolize_keys!(v) }
      when Hash
        keys = object.keys
        keys.each do |k|
          object[k.to_sym] = symbolize_keys!(object.delete(k)) if k.is_a?(String)
        end
      end
      object
    end

    def parse_regexes(path, raw_regexes)
      raw_regexes.map do |meta|
        raise "invalid device spec: #{meta.inspect}" unless meta[:regex].is_a? String

        meta[:regex] = build_regex(meta[:regex])
        meta[:path] = path
        meta
      end
    end

    def build_regex(src)
      Regexp.new('(?:^|[^A-Z0-9\-_]|[^A-Z0-9\-]_|sprd-)(?:' + src + ')', Regexp::IGNORECASE)
    end

    def from_cache(key)
      DeviceDetector.cache.get_or_set(key) { yield }
    end
  end
end
