module ISO3166
  ##
  # Handles building the in memory store of countries data
  class Data
    @@cache_dir = [File.dirname(__FILE__), 'cache']
    @@cache = {}
    @@registered_data = {}
    @@mutex = Mutex.new

    def initialize(alpha2)
      @alpha2 = alpha2.to_s.upcase
    end

    def call
      self.class.update_cache[@alpha2]
    end

    class << self
      def cache_dir
        @@cache_dir
      end

      def cache_dir=(value)
        @@cache_dir = value
      end

      def register(data)
        alpha2 = data[:alpha2].upcase
        @@registered_data[alpha2] = deep_stringify_keys(data)
        @@registered_data[alpha2]['translations'] = \
          Translations.new.merge(data['translations'] || {})
        @@cache = cache.merge(@@registered_data)
      end

      def unregister(alpha2)
        alpha2 = alpha2.to_s.upcase
        @@cache.delete(alpha2)
        @@registered_data.delete(alpha2)
      end

      def cache
        update_cache
      end

      def reset
        @@cache = {}
        @@registered_data = {}
        ISO3166.configuration.loaded_locales = []
      end

      def codes
        load_data!
        loaded_codes
      end

      def update_cache
        load_data!
        sync_translations!
        @@cache
      end

      def load_data!
        return @@cache unless load_required?
        synchronized do
          @@cache = load_cache %w(countries.json)
          @@_country_codes = @@cache.keys
          @@cache = @@cache.merge(@@registered_data)
          @@cache
        end
      end

      def sync_translations!
        return unless cache_flush_required?

        locales_to_remove.each do |locale|
          unload_translations(locale)
        end

        locales_to_load.each do |locale|
          load_translations(locale)
        end
      end

      private

      def synchronized(&block)
        if use_mutex?
          @@mutex.synchronize(&block)
        else
          block.call
        end
      end

      def use_mutex?
        # Stubbed in testing
        true
      end

      def load_required?
        synchronized do
          @@cache.empty?
        end
      end

      def loaded_codes
        @@cache.keys
      end

      # Codes that we have translations for in dataset
      def internal_codes
        @@_country_codes - @@registered_data.keys
      end

      def cache_flush_required?
        !locales_to_load.empty? || !locales_to_remove.empty?
      end

      def locales_to_load
        requested_locales - loaded_locales
      end

      def locales_to_remove
        loaded_locales - requested_locales
      end

      def requested_locales
        ISO3166.configuration.locales.map { |l| l.to_s.downcase }
      end

      def loaded_locales
        ISO3166.configuration.loaded_locales.map { |l| l.to_s.downcase }
      end

      def load_translations(locale)
        synchronized do
          locale_names = load_cache(['locales', "#{locale}.json"])
          internal_codes.each do |alpha2|
            @@cache[alpha2]['translations'] ||= Translations.new
            @@cache[alpha2]['translations'][locale] = locale_names[alpha2].freeze
            @@cache[alpha2]['translated_names'] = @@cache[alpha2]['translations'].values.freeze
          end
          ISO3166.configuration.loaded_locales << locale
        end
      end

      def unload_translations(locale)
        synchronized do
          internal_codes.each do |alpha2|
            @@cache[alpha2]['translations'].delete(locale)
            @@cache[alpha2]['translated_names'] = @@cache[alpha2]['translations'].values.freeze
          end
          ISO3166.configuration.loaded_locales.delete(locale)
        end
      end

      def load_cache(file_array)
        file_path = datafile_path(file_array)
        File.exist?(file_path) ? JSON.parse(File.binread(file_path)) : {}
      end

      def datafile_path(file_array)
        File.join([@@cache_dir] + file_array)
      end

      def deep_stringify_keys(data)
        data.transform_keys!(&:to_s)
        data.transform_values! do |v|
          v.is_a?(Hash) ? deep_stringify_keys(v) : v
        end
        return data
      end
    end
  end
end
