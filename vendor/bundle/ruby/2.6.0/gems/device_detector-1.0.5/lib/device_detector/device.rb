# frozen_string_literal: true

class DeviceDetector
  class Device < Parser
    # order is relevant for testing with fixtures
    DEVICE_NAMES = [
      'desktop',
      'smartphone',
      'tablet',
      'feature phone',
      'console',
      'tv',
      'car browser',
      'smart display',
      'camera',
      'portable media player',
      'phablet',
      'smart speaker',
      'wearable'
    ].freeze

    def known?
      regex_meta.any?
    end

    def name
      ModelExtractor.new(user_agent, regex_meta).call
    end

    def type
      hbbtv? ? 'tv' : regex_meta[:device]
    end

    def brand
      regex_meta[:brand]
    end

    private

    # The order of files needs to be the same as the order of device
    # parser classes used in the piwik project.
    def filenames
      [
        'device/televisions.yml',
        'device/consoles.yml',
        'device/car_browsers.yml',
        'device/cameras.yml',
        'device/portable_media_player.yml',
        'device/mobiles.yml',
        'device/notebooks.yml'
      ]
    end

    def matching_regex
      from_cache([self.class.name, user_agent]) do
        regex_list = hbbtv? ? regexes_for_hbbtv : regexes_other
        regex = regex_find(user_agent, regex_list)
        if regex && regex[:models]
          model_regex = regex[:models].find { |m| user_agent =~ m[:regex] }
          if model_regex
            regex = regex.merge({
                                  regex_model: model_regex[:regex],
                                  model: model_regex[:model],
                                  brand: model_regex[:brand]
                                })
            regex[:device] = model_regex[:device] if model_regex.key?(:device)
            regex.delete(:models)
          end
        end
        regex
      end
    end

    # Finds the first match of the string in a list of regexes.
    # Handles exception with special characters caused by bug in Ruby regex
    # @param user_agent [String] User Agent string
    # @param regex_list [Array<Regex>] List of regexes
    #
    # @return [MatchData, nil] MatchData if string matches any regexp, nil otherwise
    def regex_find(user_agent, regex_list)
      regex_list.find { |r| user_agent =~ r[:regex] }
    rescue RegexpError
      # Bug in ruby regex and special characters, retry with clean
      # https://bugs.ruby-lang.org/issues/13671
      user_agent = user_agent.encode(
        ::Encoding::ASCII, invalid: :replace, undef: :replace, replace: ''
      )
      regex_list.find { |r| user_agent =~ r[:regex] }
    end

    def hbbtv?
      @regex_hbbtv ||= build_regex('HbbTV/([1-9]{1}(?:\.[0-9]{1}){1,2})')
      user_agent =~ @regex_hbbtv
    end

    def regexes_for_hbbtv
      regexes.select { |r| r[:path] == :'device/televisions.yml' }
    end

    def regexes_other
      regexes.reject { |r| r[:path] == :'device/televisions.yml' }
    end

    def parse_regexes(path, raw_regexes)
      raw_regexes.map do |brand, meta|
        raise "invalid device spec: #{meta.inspect}" unless meta[:regex].is_a? String

        meta[:regex] = build_regex(meta[:regex])
        if meta.key?(:models)
          meta[:models].each do |model|
            raise "invalid model spec: #{model.inspect}" unless model[:regex].is_a? String

            model[:regex] = build_regex(model[:regex])
            model[:brand] = brand.to_s unless model[:brand]
          end
        end
        meta[:path] = path
        meta
      end
    end
  end
end
