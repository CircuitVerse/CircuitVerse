# frozen_string_literal: true

require 'yaml'

require 'device_detector/version'
require 'device_detector/metadata_extractor'
require 'device_detector/version_extractor'
require 'device_detector/model_extractor'
require 'device_detector/name_extractor'
require 'device_detector/memory_cache'
require 'device_detector/parser'
require 'device_detector/bot'
require 'device_detector/client'
require 'device_detector/device'
require 'device_detector/os'

class DeviceDetector
  attr_reader :user_agent

  def initialize(user_agent)
    @user_agent = user_agent
  end

  def name
    client.name
  end

  def full_version
    client.full_version
  end

  def os_family
    os.family
  end

  def os_name
    os.name
  end

  def os_full_version
    os.full_version
  end

  def device_name
    device.name
  end

  def device_brand
    device.brand
  end

  def device_type
    t = device.type

    # Chrome on Android passes the device type based on the keyword 'Mobile'
    # If it is present the device should be a smartphone, otherwise it's a tablet
    # See https://developer.chrome.com/multidevice/user-agent#chrome_for_android_user_agent
    # Note: We do not check for browser (family) here, as there might be mobile apps using Chrome,
    # that won't have a detected browser, but can still be detected. So we check the useragent for
    # Chrome instead.
    if t.nil? && os.family == 'Android' && user_agent =~ build_regex('Chrome\/[\.0-9]*')
      if user_agent =~ build_regex('Chrome\/[\.0-9]* Mobile')
        t = 'smartphone'
      elsif user_agent =~ build_regex('Chrome\/[\.0-9]* (?!Mobile)')
        t = 'tablet'
      end
    end

    t = 'tablet' if t.nil? && android_tablet_fragment? || opera_tablet?

    t = 'smartphone' if t.nil? && android_mobile_fragment?

    # Android up to 3.0 was designed for smartphones only. But as 3.0,
    # which was tablet only, was published too late, there were a
    # bunch of tablets running with 2.x With 4.0 the two trees were
    # merged and it is for smartphones and tablets
    #
    # So were are expecting that all devices running Android < 2 are
    # smartphones Devices running Android 3.X are tablets. Device type
    # of Android 2.X and 4.X+ are unknown
    if t.nil? && os.short_name == 'AND' && os.full_version && !os.full_version.empty?
      if os.full_version < '2'
        t = 'smartphone'
      elsif os.full_version >= '3' && os.full_version < '4'
        t = 'tablet'
      end
    end

    # All detected feature phones running android are more likely a smartphone
    t = 'smartphone' if t == 'feature phone' && os.family == 'Android'

    # According to http://msdn.microsoft.com/en-us/library/ie/hh920767(v=vs.85).aspx
    # Internet Explorer 10 introduces the "Touch" UA string token. If this token is present at the
    # end of the UA string, the computer has touch capability, and is running Windows 8 (or later).
    # This UA string will be transmitted on a touch-enabled system running Windows 8 (RT)
    #
    # As most touch enabled devices are tablets and only a smaller part are desktops/notebooks we
    # assume that all Windows 8 touch devices are tablets.
    if t.nil? && touch_enabled? &&
       (os.short_name == 'WRT' || (os.short_name == 'WIN' && os.full_version && os.full_version >= '8'))
      t = 'tablet'
    end

    t = 'tv' if opera_tv_store?

    t = 'tv' if t.nil? && ['Kylo', 'Espial TV Browser'].include?(client.name)

    # set device type to desktop for all devices running a desktop os that were
    # not detected as an other device type
    t = 'desktop' if t.nil? && os.desktop? && !puffin_browser?

    t
  end

  def known?
    client.known?
  end

  def bot?
    bot.bot?
  end

  def bot_name
    bot.name
  end

  class << self
    class Configuration
      attr_accessor :max_cache_keys

      def to_hash
        {
          max_cache_keys: max_cache_keys
        }
      end
    end

    def config
      @config ||= Configuration.new
    end

    def cache
      @cache ||= MemoryCache.new(config.to_hash)
    end

    def configure
      @config = Configuration.new
      yield(config)
    end
  end

  private

  def bot
    @bot ||= Bot.new(user_agent)
  end

  def client
    @client ||= Client.new(user_agent)
  end

  def device
    @device ||= Device.new(user_agent)
  end

  def os
    @os ||= OS.new(user_agent)
  end

  def android_tablet_fragment?
    user_agent =~ build_regex('Android(?: \d.\d(?:.\d)?)?; Tablet;')
  end

  def android_mobile_fragment?
    user_agent =~ build_regex('Android(?: \d.\d(?:.\d)?)?; Mobile;')
  end

  def touch_enabled?
    user_agent =~ build_regex('Touch')
  end

  def opera_tv_store?
    user_agent =~ build_regex('Opera TV Store')
  end

  def opera_tablet?
    user_agent =~ build_regex('Opera Tablet')
  end

  # This is a workaround until we support detecting mobile only browsers
  def puffin_browser?
    client.name == 'Puffin'
  end

  def build_regex(src)
    Regexp.new('(?:^|[^A-Z0-9\_\-])(?:' + src + ')', Regexp::IGNORECASE)
  end
end
