# frozen_string_literal: true

require 'set'

class DeviceDetector
  class OS < Parser
    class << self
      def mapped_os_version(version, mapping)
        return if version.nil?

        major_version = version.split('.').first

        mapping[version] || mapping[major_version]
      end
    end

    def name
      os_info[:name]
    end

    def short_name
      os_info[:short]
    end

    def family
      os_info[:family]
    end

    def desktop?
      DESKTOP_OSS.include?(family)
    end

    def full_version
      raw_version = super.to_s.split('_').join('.')
      raw_version == '' ? nil : raw_version
    end

    private

    def os_info
      from_cache(['os_info', self.class.name, user_agent]) do
        os_name = NameExtractor.new(user_agent, regex_meta).call
        if os_name && (short = DOWNCASED_OPERATING_SYSTEMS[os_name.downcase])
          os_name = OPERATING_SYSTEMS[short]
        else
          short = 'UNK'
        end
        { name: os_name, short: short, family: FAMILY_TO_OS[short] }
      end
    end

    # https://github.com/matomo-org/device-detector/blob/75d88bbefb0182f9207c9f48dc39b1bc8c7cc43f/Parser/OperatingSystem.php#L286-L288
    DESKTOP_OSS = Set.new(
      [
        'AmigaOS', 'IBM', 'GNU/Linux', 'Mac', 'Unix', 'Windows', 'BeOS', 'Chrome OS', 'Chromium OS'
      ]
    )

    # OS short codes mapped to long names
    # https://github.com/matomo-org/device-detector/blob/75d88bbefb0182f9207c9f48dc39b1bc8c7cc43f/Parser/OperatingSystem.php#L42-L220
    OPERATING_SYSTEMS = {
      'AIX' => 'AIX',
      'AND' => 'Android',
      'ADR' => 'Android TV',
      'ALP' => 'Alpine Linux',
      'AMZ' => 'Amazon Linux',
      'AMG' => 'AmigaOS',
      'ARM' => 'Armadillo OS',
      'ARO' => 'AROS',
      'ATV' => 'tvOS',
      'ARL' => 'Arch Linux',
      'AOS' => 'AOSC OS',
      'ASP' => 'ASPLinux',
      'BTR' => 'BackTrack',
      'SBA' => 'Bada',
      'BYI' => 'Baidu Yi',
      'BEO' => 'BeOS',
      'BLB' => 'BlackBerry OS',
      'QNX' => 'BlackBerry Tablet OS',
      'BOS' => 'Bliss OS',
      'BMP' => 'Brew',
      'BSN' => 'BrightSignOS',
      'CAI' => 'Caixa Mágica',
      'CES' => 'CentOS',
      'CST' => 'CentOS Stream',
      'CLO' => 'Clear Linux OS',
      'CLR' => 'ClearOS Mobile',
      'COS' => 'Chrome OS',
      'CRS' => 'Chromium OS',
      'CHN' => 'China OS',
      'CYN' => 'CyanogenMod',
      'DEB' => 'Debian',
      'DEE' => 'Deepin',
      'DFB' => 'DragonFly',
      'DVK' => 'DVKBuntu',
      'ELE' => 'ElectroBSD',
      'EUL' => 'EulerOS',
      'FED' => 'Fedora',
      'FEN' => 'Fenix',
      'FOS' => 'Firefox OS',
      'FIR' => 'Fire OS',
      'FOR' => 'Foresight Linux',
      'FRE' => 'Freebox',
      'BSD' => 'FreeBSD',
      'FRI' => 'FRITZ!OS',
      'FYD' => 'FydeOS',
      'FUC' => 'Fuchsia',
      'GNT' => 'Gentoo',
      'GNX' => 'GENIX',
      'GEO' => 'GEOS',
      'GNS' => 'gNewSense',
      'GRI' => 'GridOS',
      'GTV' => 'Google TV',
      'HPX' => 'HP-UX',
      'HAI' => 'Haiku OS',
      'IPA' => 'iPadOS',
      'HAR' => 'HarmonyOS',
      'HAS' => 'HasCodingOS',
      'HEL' => 'HELIX OS',
      'IRI' => 'IRIX',
      'INF' => 'Inferno',
      'JME' => 'Java ME',
      'JOL' => 'Joli OS',
      'KOS' => 'KaiOS',
      'KAL' => 'Kali',
      'KAN' => 'Kanotix',
      'KIN' => 'KIN OS',
      'KNO' => 'Knoppix',
      'KTV' => 'KreaTV',
      'KBT' => 'Kubuntu',
      'LIN' => 'GNU/Linux',
      'LND' => 'LindowsOS',
      'LNS' => 'Linspire',
      'LEN' => 'Lineage OS',
      'LIR' => 'Liri OS',
      'LOO' => 'Loongnix',
      'LBT' => 'Lubuntu',
      'LOS' => 'Lumin OS',
      'LUN' => 'LuneOS',
      'VLN' => 'VectorLinux',
      'MAC' => 'Mac',
      'MAE' => 'Maemo',
      'MAG' => 'Mageia',
      'MDR' => 'Mandriva',
      'SMG' => 'MeeGo',
      'MCD' => 'MocorDroid',
      'MON' => 'moonOS',
      'EZX' => 'Motorola EZX',
      'MIN' => 'Mint',
      'MLD' => 'MildWild',
      'MOR' => 'MorphOS',
      'NBS' => 'NetBSD',
      'MTK' => 'MTK / Nucleus',
      'MRE' => 'MRE',
      'NXT' => 'NeXTSTEP',
      'NWS' => 'NEWS-OS',
      'WII' => 'Nintendo',
      'NDS' => 'Nintendo Mobile',
      'NOV' => 'Nova',
      'OS2' => 'OS/2',
      'T64' => 'OSF1',
      'OBS' => 'OpenBSD',
      'OVS' => 'OpenVMS',
      'OVZ' => 'OpenVZ',
      'OWR' => 'OpenWrt',
      'OTV' => 'Opera TV',
      'ORA' => 'Oracle Linux',
      'ORD' => 'Ordissimo',
      'PAR' => 'Pardus',
      'PCL' => 'PCLinuxOS',
      'PIC' => 'PICO OS',
      'PLA' => 'Plasma Mobile',
      'PSP' => 'PlayStation Portable',
      'PS3' => 'PlayStation',
      'PVE' => 'Proxmox VE',
      'PUR' => 'PureOS',
      'QTP' => 'Qtopia',
      'PIO' => 'Raspberry Pi OS',
      'RAS' => 'Raspbian',
      'RHT' => 'Red Hat',
      'RST' => 'Red Star',
      'RED' => 'RedOS',
      'REV' => 'Revenge OS',
      'ROS' => 'RISC OS',
      'ROC' => 'Rocky Linux',
      'ROK' => 'Roku OS',
      'RSO' => 'Rosa',
      'ROU' => 'RouterOS',
      'REM' => 'Remix OS',
      'RRS' => 'Resurrection Remix OS',
      'REX' => 'REX',
      'RZD' => 'RazoDroiD',
      'SAB' => 'Sabayon',
      'SSE' => 'SUSE',
      'SAF' => 'Sailfish OS',
      'SCI' => 'Scientific Linux',
      'SEE' => 'SeewoOS',
      'SER' => 'SerenityOS',
      'SIR' => 'Sirin OS',
      'SLW' => 'Slackware',
      'SOS' => 'Solaris',
      'SBL' => 'Star-Blade OS',
      'SYL' => 'Syllable',
      'SYM' => 'Symbian',
      'SYS' => 'Symbian OS',
      'S40' => 'Symbian OS Series 40',
      'S60' => 'Symbian OS Series 60',
      'SY3' => 'Symbian^3',
      'TEN' => 'TencentOS',
      'TDX' => 'ThreadX',
      'TIZ' => 'Tizen',
      'TIV' => 'TiVo OS',
      'TOS' => 'TmaxOS',
      'TUR' => 'Turbolinux',
      'UBT' => 'Ubuntu',
      'ULT' => 'ULTRIX',
      'UOS' => 'UOS',
      'VID' => 'VIDAA',
      'WAS' => 'watchOS',
      'WER' => 'Wear OS',
      'WTV' => 'WebTV',
      'WHS' => 'Whale OS',
      'WIN' => 'Windows',
      'WCE' => 'Windows CE',
      'WIO' => 'Windows IoT',
      'WMO' => 'Windows Mobile',
      'WPH' => 'Windows Phone',
      'WRT' => 'Windows RT',
      'WPO' => 'WoPhone',
      'XBX' => 'Xbox',
      'XBT' => 'Xubuntu',
      'YNS' => 'YunOS',
      'ZEN' => 'Zenwalk',
      'ZOR' => 'ZorinOS',
      'IOS' => 'iOS',
      'POS' => 'palmOS',
      'WEB' => 'Webian',
      'WOS' => 'webOS'
    }.freeze

    DOWNCASED_OPERATING_SYSTEMS = OPERATING_SYSTEMS.each_with_object({}) do |(short, long), h|
      h[long.downcase] = short
    end.freeze

    APPLE_OS_NAMES = Set.new(%w[iPadOS tvOS watchOS iOS Mac]).freeze

    # https://github.com/matomo-org/device-detector/blob/75d88bbefb0182f9207c9f48dc39b1bc8c7cc43f/Parser/OperatingSystem.php#L227-L269
    OS_FAMILIES = {
      'Android' => %w[ AND CYN FIR REM RZD MLD MCD YNS GRI HAR
                       ADR CLR BOS REV LEN SIR RRS WER PIC ARM
                       HEL BYI],
      'AmigaOS' => %w[AMG MOR ARO],
      'BlackBerry' => %w[BLB QNX],
      'Brew' => ['BMP'],
      'BeOS' => %w[BEO HAI],
      'Chrome OS' => %w[COS CRS FYD SEE],
      'Firefox OS' => %w[FOS KOS],
      'Gaming Console' => %w[WII PS3],
      'Google TV' => ['GTV'],
      'IBM' => ['OS2'],
      'iOS' => %w[IOS ATV WAS IPA],
      'RISC OS' => ['ROS'],
      'GNU/Linux' => %w[
        LIN ARL DEB KNO MIN UBT KBT XBT LBT FED
        RHT VLN MDR GNT SAB SLW SSE CES BTR SAF
        ORD TOS RSO DEE FRE MAG FEN CAI PCL HAS
        LOS DVK ROK OWR OTV KTV PUR PLA FUC PAR
        FOR MON KAN ZEN LND LNS CHN AMZ TEN CST
        NOV ROU ZOR RED KAL ORA VID TIV BSN RAS
        UOS PIO FRI LIR WEB SER ASP AOS LOO EUL
        SCI ALP CLO ROC OVZ PVE RST EZX GNS JOL
        TUR QTP WPO
      ],
      'Mac' => ['MAC'],
      'Mobile Gaming Console' => %w[PSP NDS XBX],
      'OpenVMS' => ['OVS'],
      'Real-time OS' => %w[MTK TDX MRE JME REX],
      'Other Mobile' => %w[WOS POS SBA TIZ SMG MAE LUN GEO],
      'Symbian' => %w[SYM SYS SY3 S60 S40],
      'Unix' => %w[
        SOS AIX HPX BSD NBS OBS DFB SYL IRI T64
        INF ELE GNX ULT NWS NXT SBL
      ],
      'WebTV' => ['WTV'],
      'Windows' => ['WIN'],
      'Windows Mobile' => %w[WPH WMO WCE WRT WIO KIN],
      'Other Smart TV' => ['WHS']
    }.freeze

    FAMILY_TO_OS = OS_FAMILIES.each_with_object({}) do |(family, oss), h|
      oss.each { |os| h[os] = family }
    end.freeze

    # https://github.com/matomo-org/device-detector/blob/75d88bbefb0182f9207c9f48dc39b1bc8c7cc43f/Parser/OperatingSystem.php#L295-L308
    FIRE_OS_VERSION_MAPPING = {
      '11' => '8',
      '10' => '8',
      '9' => '7',
      '7' => '6',
      '5' => '5',
      '4.4.3' => '4.5.1',
      '4.4.2' => '4',
      '4.2.2' => '3',
      '4.0.3' => '3',
      '4.0.2' => '3',
      '4' => '2',
      '2' => '1',
    }.freeze

    # https://github.com/matomo-org/device-detector/blob/75d88bbefb0182f9207c9f48dc39b1bc8c7cc43f/Parser/OperatingSystem.php#L315-L337
    LINEAGE_OS_VERSION_MAPPING = {
      '14' => '21',
      '13' => '20.0',
      '12.1' => '19.1',
      '12' => '19.0',
      '11' => '18.0',
      '10' => '17.0',
      '9' => '16.0',
      '8.1.0' => '15.1',
      '8.0.0' => '15.0',
      '7.1.2' => '14.1',
      '7.1.1' => '14.1',
      '7.0' => '14.0',
      '6.0.1' => '13.0',
      '6.0' => '13.0',
      '5.1.1' => '12.1',
      '5.0.2' => '12.0',
      '5.0' => '12.0',
      '4.4.4' => '11.0',
      '4.3' => '10.2',
      '4.2.2' => '10.1',
      '4.0.4' => '9.1.0'
    }.freeze

    def filenames
      ['oss.yml']
    end
  end
end
