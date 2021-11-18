# DeviceDetector

[![Build Status](https://travis-ci.org/podigee/device_detector.svg?branch=develop)](https://travis-ci.org/podigee/device_detector)

DeviceDetector is a precise and fast user agent parser and device detector written in Ruby, backed by the largest and most up-to-date user agent database.

DeviceDetector will parse any user agent and detect the browser, operating system, device used (desktop, tablet, mobile, tv, cars, console, etc.), brand and model. DeviceDetector detects thousands of user agent strings, even from rare and obscure browsers and devices.

The DeviceDetector is optimized for speed of detection, by providing optimized code and in-memory caching.

This project originated as a Ruby port of the Universal Device Detection library.
You can find the original code here: https://github.com/piwik/device-detector.

## Disclaimer

This port does not aspire to be a one-to-one copy from the original code, but rather an adaptation for the Ruby language.

Still, our goal is to use the original, unchanged regex yaml files, in order to mutually benefit from updates and pull request to both the original and the ported versions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'device_detector'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install device_detector

## Usage

```ruby
user_agent = 'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.17 Safari/537.36'
client = DeviceDetector.new(user_agent)

client.name # => 'Chrome'
client.full_version # => '30.0.1599.69'

client.os_name # => 'Windows'
client.os_full_version # => '8'

# For many devices, you can also query the device name (usually the model name)
client.device_name # => 'iPhone 5'
# Device types can be one of the following: desktop, smartphone, tablet, console,
# portable media player, tv, car browser, camera
client.device_type # => 'smartphone'
```

`DeviceDetector` will return `nil` on all attributes, if the `user_agent` is unknown.
You can make a check to ensure the client has been detected:

```ruby
client.known? # => will return false if user_agent is unknown
```

### Memory cache

`DeviceDetector` will cache up 5,000 user agent strings to boost parsing performance.
You can tune the amount of keys that will get saved in the cache. You have to call this code **before** you initialize the Detector.

```ruby
DeviceDetector.configure do |config|
  config.max_cache_keys = 5_000 # increment this if you have enough RAM, proceed with care
end
```

If you have a Rails application, you can create an initializer, for example `config/initializers/device_detector.rb`.

## Benchmarks

We have measured the parsing speed of almost 200,000 non-unique user agent strings and compared the speed of DeviceDetector with the two most popular user agent parsers in the Ruby community, Browser and UserAgent.

### Testing machine specs

- MacBook Pro 15", Late 2013
- 2.6 GHz Intel Core i7
- 16 GB 1600 MHz DDR3

### Gem versions

- DeviceDetector - 0.5.1
- Browser - 0.8.0
- UserAgent - 0.13.1

### Code

```ruby
require 'device_detector'
require 'browser'
require 'user_agent'
require 'benchmark'

user_agent_strings = File.read('./tmp/user_agent_strings.txt').split("\n")

## Benchmarks

Benchmark.bm(15) do |x|
  x.report('device_detector') {
    user_agent_strings.each { |uas| DeviceDetector.new(uas).name }
  }
  x.report('browser') {
    user_agent_strings.each { |uas| Browser.new(ua: uas).name }
  }
  x.report('useragent') {
    user_agent_strings.each { |uas| UserAgent.parse(uas).browser }
  }
end
```

### Results

```
                      user     system      total        real
device_detector   1.180000   0.010000   1.190000 (  1.198721)
browser           2.240000   0.010000   2.250000 (  2.245493)
useragent         4.490000   0.020000   4.510000 (  4.500673)

                      user     system      total        real
device_detector   1.190000   0.020000   1.210000 (  1.201447)
browser           2.250000   0.010000   2.260000 (  2.261001)
useragent         4.440000   0.010000   4.450000 (  4.451693)

                      user     system      total        real
device_detector   1.210000   0.020000   1.230000 (  1.228617)
browser           2.220000   0.010000   2.230000 (  2.222565)
useragent         4.450000   0.000000   4.450000 (  4.452741)
```

## Detectable clients, bots and devices

Updated on 2020-10-06

### Bots

360Spider, Aboundexbot, Acoon, AddThis.com, ADMantX, ADmantX Service Fetcher, aHrefs Bot, Alexa Crawler, Alexa Site Audit, Amazon Route53 Health Check, Amorank Spider, Analytics SEO Crawler, ApacheBench, Applebot, Arachni, archive.org bot, Ask Jeeves, AspiegelBot, Awario, Backlink-Check.de, BacklinkCrawler, Baidu Spider, Barkrowler, BazQux Reader, BingBot, BitlyBot, Blekkobot, BLEXBot Crawler, Bloglovin, Blogtrottr, BoardReader, BoardReader Blog Indexer, Bountii Bot, BrandVerity, Browsershots, BUbiNG, Buck, Butterfly Robot, Bytespider, CareerBot, Castro 2, Catchpoint, CATExplorador, ccBot crawler, Charlotte, Cliqzbot, CloudFlare Always Online, CloudFlare AMP Fetcher, Collectd, CommaFeed, CSS Certificate Spider, Cốc Cốc Bot, Datadog Agent, Datanyze, Dataprovider, Daum, Dazoobot, Discobot, Domain Re-Animator Bot, Domains Project, DotBot, DuckDuckGo Bot, Easou Spider, eCairn-Grabber, EMail Exractor, EmailWolf, Embedly, evc-batch, ExaBot, ExactSeek Crawler, eZ Publish Link Validator, Ezooms, Facebook External Hit, Feed Wrangler, Feedbin, FeedBurner, Feedly, Feedspot, Fever, Findxbot, Flipboard, FreshRSS, Generic Bot, Genieo Web filter, Gigablast, Gigabot, Gluten Free Crawler, Gmail Image Proxy, Goo, Google Cloud Scheduler, Google Favicon, Google PageSpeed Insights, Google Partner Monitoring, Google Search Console, Google Stackdriver Monitoring, Google Structured Data Testing Tool, Googlebot, Grammarly, Grapeshot, GTmetrix, Heritrix, Heureka Feed, HTTPMon, HubPages, HubSpot, ICC-Crawler, ichiro, IDG/IT, IIS Site Analysis, Inktomi Slurp, inoreader, IP-Guide Crawler, IPS Agent, Kaspersky, Kouio, Larbin web crawler, LCC, Let's Encrypt Validation, Lighthouse, Linkdex Bot, LinkedIn Bot, LTX71, Lycos, Magpie-Crawler, MagpieRSS, Mail.Ru Bot, masscan, Mastodon Bot, Meanpath Bot, MetaInspector, MetaJobBot, Mixrank Bot, MJ12 Bot, Mnogosearch, MojeekBot, Monitor.Us, Munin, Nagios check_http, NalezenCzBot, nbertaupete95, Netcraft Survey Bot, netEstate, NetLyzer FastProbe, NetResearchServer, Netvibes, NewsBlur, NewsGator, NLCrawler, Nmap, Nutch-based Bot, Nuzzel, oBot, Octopus, Omgili bot, Openindex Spider, OpenLinkProfiler, OpenWebSpider, Orange Bot, Outbrain, PagePeeker, PaperLiBot, Petal Bot, Phantomas, PHP Server Monitor, Picsearch bot, Pingdom Bot, Pinterest, PocketParser, Pompos, PritTorrent, QuerySeekerSpider, Quora Link Preview, Qwantify, Rainmeter, RamblerMail Image Proxy, Reddit Bot, Riddler, Robozilla, Rogerbot, ROI Hunter, RSSRadio Bot, SafeDNSBot, Scooter, ScoutJet, Scrapy, Screaming Frog SEO Spider, ScreenerBot, Semantic Scholar Bot, Semrush Bot, Sensika Bot, Sentry Bot, Seobility, SEOENGBot, SEOkicks-Robot, Seoscanners.net, Serendeputy Bot, Server Density, Seznam Bot, Seznam Email Proxy, Seznam Zbozi.cz, ShopAlike, Shopify Partner, ShopWiki, SilverReader, SimplePie, SISTRIX Crawler, SISTRIX Optimizer, Site24x7 Website Monitoring, Siteimprove, SiteSucker, Sixy.ch, Skype URI Preview, Slackbot, SMTBot, Snapchat Proxy, Sogou Spider, Soso Spider, Sparkler, Speedy, Spinn3r, Spotify, Sputnik Bot, sqlmap, SSL Labs, Startpagina Linkchecker, StatusCake, Superfeedr Bot, Survey Bot, Tarmot Gezgin, TelegramBot, The Knowledge AI, theoldreader, TinEye Crawler, Tiny Tiny RSS, TLSProbe, TraceMyFile, Trendiction Bot, TurnitinBot, TweetedTimes Bot, Tweetmeme Bot, Twingly Recon, Twitterbot, UkrNet Mail Proxy, UniversalFeedParser, Uptime Robot, Uptimebot, URLAppendBot, Vagabondo, Velen Public Web Crawler, Vercel Bot, Visual Site Mapper Crawler, VK Share Button, W3C CSS Validator, W3C I18N Checker, W3C Link Checker, W3C Markup Validation Service, W3C MobileOK Checker, W3C Unified Validator, Wappalyzer, WebbCrawler, Weborama, WebPageTest, WebSitePulse, WebThumbnail, WeSEE:Search, WikiDo, Willow Internet Crawler, WooRank, WordPress, Wotbox, XenForo, YaCy, Yahoo Gemini, Yahoo! Cache System, Yahoo! Japan BRW, Yahoo! Link Preview, Yahoo! Slurp, Yandex Bot, Yeti/Naverbot, Yottaa Site Monitor, Youdao Bot, Yourls, Yunyun Bot, Zao, Ze List, zgrab, Zookabot, ZumBot

### Clients

115 Browser, 2345 Browser, 360 Browser, 360 Phone Browser, ABrowse, aiohttp, Airmail, Akregator, Aloha Browser, Aloha Browser Lite, Amaya, Amiga Aweb, Amiga Voyager, Amigo, Android Browser, AndroidDownloadManager, ANT Fresco, AntennaPod, ANTGalio, AOL Desktop, AOL Shield, Apple News, Apple PubSub, Arctic Fox, Arora, Atom, Atomic Web Browser, Audacious, Avant Browser, Avast Secure Browser, AVG Secure Browser, B-Line, Baidu Box App, Baidu Browser, Baidu Spark, Banshee, Barca, BashPodder, Basilisk, Beaker Browser, Beamrise, Beonex, BeyondPod, BingWebApp, BlackBerry Browser, BlackHawk, Blue Browser, Boxee, bPod, Brave, Breaker, BriskBard, BrowseX, Bunjalloo, Camino, CastBox, Castro, Castro 2, CCleaner, Centaury, Charon, Cheetah Browser, Cheshire, Chrome, Chrome Frame, Chrome Mobile, Chrome Mobile iOS, Chrome Webview, ChromePlus, Chromium, Clementine, CM Browser, Coast, Coc Coc, Colibri, CometBird, Comodo Dragon, Conkeror, CoolNovo, COS Browser, CrosswalkApp, Crusta, Cunaguaro, curl, Cyberfox, DAVdroid, dbrowser, Deepnet Explorer, Deezer, Delta Browser, Dillo, DingTalk, DoggCatcher, Dolphin, Dooble, Dorado, douban App, Downcast, DuckDuckGo Privacy Browser, Ecosia, Element Browser, Elements Browser, Elinks, Epic, Espial TV Browser, EUI Browser, eZ Browser, Facebook, Facebook Messenger, Falkon, Faraday, Faux Browser, FeedDemon, Feeddler RSS Reader, FeedR, Fennec, Firebird, Firefox, Firefox Focus, Firefox Mobile, Firefox Mobile iOS, Firefox Reality, Firefox Rocket, Fireweb, Fireweb Navigator, Flipboard App, Flock, Fluid, FlyCast, Foobar2000, FreeU, Galeon, Glass Browser, GNOME Web, Go-http-client, GOG Galaxy, Google Earth, Google Go, Google HTTP Java Client, Google Play Newsstand, Google Plus, Google Podcasts, Google Search App, gPodder, Guzzle (PHP HTTP Client), Hawk Turbo Browser, Headless Chrome, HeyTapBrowser, hola! Browser, HotJava, HTTP_Request2, HTTPie, Huawei Browser, IBrowse, iCab, iCab Mobile, iCatcher, IceCat, IceDragon, Iceweasel, IE Mobile, Instacast, Instagram App, Internet Explorer, Iridium, Iron, Iron Mobile, Isivioo, iTunes, Jasmine, Java, JetBrains Omea Reader, Jig Browser, Jig Browser Plus, Jio Browser, K-meleon, K.Browser, Kapiko, Kazehakase, Kindle Browser, Kinza, Kiwi, Kodi, Konqueror, Kylo, LG Browser, libdnf, LieBaoFast, Liferea, Light, Line, LinkedIn, Links, Lotus Notes, Lovense Browser, LuaKit, Lulumi, Lunascape, Lunascape Lite, Lynx, MailBar, Maxthon, mCent, Mechanize, MediaMonkey, Meizu Browser, Mercury, MicroB, Microsoft Edge, Microsoft Outlook, Midori, Minimo, Mint Browser, Miro, MIUI Browser, Mobicip, Mobile Safari, Mobile Silk, mpv, Music Player Daemon, Mypal, NCSA Mosaic, NetFront, NetFront Life, NetNewsWire, NetPositive, Netscape, NetSurf, NewsArticle App, Newsbeuter, NewsBlur, NewsBlur Mobile App, NexPlayer, Nightingale, Node Fetch, Nokia Browser, Nokia OSS Browser, Nokia Ovi Browser, Nox Browser, NTENT Browser, Obigo, Oculus Browser, Odyssey Web Browser, Off By One, OhHai Browser, OkHttp, OmniWeb, ONE Browser, Openwave Mobile Browser, Opera, Opera Devices, Opera GX, Opera Mini, Opera Mini iOS, Opera Mobile, Opera Neon, Opera Next, Opera Touch, Oppo Browser, Ordissimo, Oregano, Origin In-Game Overlay, Origyn Web Browser, Otter Browser, Outlook Express, Overcast, Pale Moon, Palm Blazer, Palm Pre, Palm WebPro, Palmscape, Perl, Perl REST::Client, Phoenix, Pinterest, Player FM, Pocket Casts, Podcast & Radio Addict, Podcast Republic, Podcasts, Podcat, Podcatcher Deluxe, Podkicker, Polaris, Polarity, Polypane, Postbox, PritTorrent, Puffin, Pulp, Python Requests, Python urllib, QQ Browser, QQ Browser Mini, QtWebEngine, Quark, QuickTime, QuiteRSS, QupZilla, Qutebrowser, Qwant Mobile, ReactorNetty, ReadKit, Realme Browser, Reeder, Rekonq, REST Client for Ruby, RestSharp, Roblox, RockMelt, RSS Bandit, RSS Junkie, RSSOwl, RSSRadio, Safari, Safe Exam Browser, Sailfish Browser, SalamWeb, Samsung Browser, ScalaJ HTTP, SeaMonkey, SEMC-Browser, Seraphic Sraf, Seznam Browser, Shiira, SimpleBrowser, Sina Weibo, Siri, Sizzy, Skyfire, Sleipnir, Snapchat, Snowshoe, Sogou Explorer, Sogou Mobile Browser, SogouSearch App, Songbird, Splash, Sputnik Browser, Stagefright, START Internet Browser, Steam In-Game Overlay, Streamy, Stringer, SubStream, Sunrise, Super Fast Browser, SuperBird, surf, Swiftfox, t-online.de Browser, Tao Browser, TenFourFox, Tenta Browser, The Bat!, Thunderbird, tieba, Tizen Browser, ToGate, TopBuzz, Tungsten, TV Bro, TweakStyle, Twitter, U-Cursos, UBrowser, UC Browser, UC Browser Mini, UC Browser Turbo, UnityPlayer, urlgrabber (yum), Uzbl, Viber, Vision Mobile Browser, Vivaldi, vivo Browser, VLC, VMware AirWatch, Waterfox, Wear Internet Browser, Web Explorer, WebPositive, WeChat, WeTab Browser, Wget, Whale Browser, WhatsApp, Winamp, Windows Media Player, wOSBrowser, WWW-Mechanize, XBMC, Xiino, Xvast, Yaani Browser, Yahoo! Japan, Yahoo! Japan Browser, Yandex Browser, Yandex Browser Lite, Yelp Mobile, YouTube, Zvu

### Devices

2E, 360, 3Q, 4Good, Accent, Ace, Acer, Advan, Advance, AGM, Ainol, Airness, Airties, AIS, Aiwa, Akai, Alba, Alcatel, Alfawise, Aligator, AllCall, AllDocube, Allview, Allwinner, Altech UEC, altron, Amazon, AMGOO, Amigoo, Amoi, Anry, ANS, Aoson, Apple, Archos, Arian Space, Ark, ArmPhone, Arnova, ARRIS, Asano, Ask, Assistant, Asus, AT&T, Atom, Audiovox, Avenzo, AVH, Avvio, Axxion, Azumi Mobile, BangOlufsen, Barnes & Noble, BB Mobile, BDF, Becker, Beeline, Beelink, Beetel, BenQ, BenQ-Siemens, Bezkam, BGH, BIHEE, Billion, Bird, Bitel, Bitmore, Black Fox, Blackview, Blaupunkt, Blu, Bluboo, Bluegood, Bmobile, Bobarry, bogo, Boway, bq, Bravis, Brondi, Bush, CAGI, Capitel, Captiva, Carrefour, Casio, Casper, Cat, Celkon, Changhong, Cherry Mobile, China Mobile, Chuwi, Clarmin, Cloudfone, Clout, CnM, Coby Kyros, Comio, Compal, ComTrade Tesla, Concord, ConCorde, Condor, Contixo, Coolpad, Cowon, CreNova, Crescent, Cricket, Crius Mea, Crony, Crosscall, Cube, CUBOT, CVTE, Cyrus, Daewoo, Danew, Datang, Datawind, Datsun, Dbtel, Dell, Denver, Desay, DeWalt, DEXP, Dialog, Dicam, Digi, Digicel, Digiland, Digma, Divisat, DMM, DNS, DoCoMo, Doffler, Dolamee, Doogee, Doopro, Doov, Dopod, Doro, Droxio, Dune HD, E-Boda, E-Ceros, E-tel, Easypix, EBEST, Echo Mobiles, ECS, EE, EKO, Eks Mobility, Element, Elenberg, Elephone, Eltex, Energizer, Energy Sistem, Enot, Ergo, Ericsson, Ericy, Essential, Essentielb, Eton, eTouch, Etuline, Eurostar, Evercoss, Evertek, Evolio, Evolveo, EvroMedia, Explay, Extrem, Ezio, Ezze, Fairphone, Famoco, Fengxiang, FiGO, FinePower, FireFly Mobile, Fly, FNB, Fondi, FORME, Forstar, Foxconn, Freetel, Fujitsu, G-TiDE, Garmin-Asus, Gemini, General Mobile, Geotel, Ghia, Ghong, Gigabyte, Gigaset, Ginzzu, Gionee, Globex, GOCLEVER, Goly, Gome, GoMobile, Google, Goophone, Gradiente, Grape, Gree, Grundig, Hafury, Haier, HannSpree, Hasee, Hi-Level, Highscreen, Hisense, Hoffmann, Homtom, Hoozo, Hosin, Hotwav, How, HP, HTC, Huadoo, Huawei, Humax, Hyundai, i-Cherry, i-Joy, i-mate, i-mobile, iBall, iBerry, IconBIT, iDroid, iGet, iHunt, Ikea, iKoMo, iLA, iLife, iMars, IMO Mobile, Impression, iNew, Infinix, InFocus, Inkti, InnJoo, Innostream, Inoi, INQ, Insignia, Intek, Intex, Inverto, Invin, iOcean, iPro, IQM, Irbis, iRola, iRulu, iTel, iTruck, iVA, iView, iZotron, JAY-Tech, JFone, Jiayu, Jinga, JKL, Jolla, Just5, K-Touch, Kaan, Kaiomy, Kalley, Kanji, Karbonn, KATV1, Kazam, KDDI, Kempler & Strauss, Keneksi, Kenxinda, Kiano, Kingsun, Kivi, Klipad, Kocaso, Kodak, Kogan, Komu, Konka, Konrow, Koobee, Kooper, KOPO, Koridy, KRONO, Krüger&Matz, KT-Tech, Kuliao, Kumai, Kyocera, Kzen, LAIQ, Land Rover, Landvo, Lanix, Lark, Lava, LCT, Le Pan, Leagoo, Ledstar, LeEco, Lemhoov, Lenco, Lenovo, Leotec, Lephone, Lesia, Lexand, Lexibook, LG, Lingwin, Loewe, Logic, Logicom, Lumigon, Lumus, Luna, LYF, M.T.T., M4tel, Macoox, Majestic, Mann, Manta Multimedia, Masstel, Maxcom, Maxtron, MAXVI, Maxwest, Maze, meanIT, Mecer, Mecool, Mediacom, MediaTek, Medion, MEEG, MegaFon, Meitu, Meizu, Melrose, Memup, Metz, MEU, MicroMax, Microsoft, Minix, Mio, Miray, Mito, Mitsubishi, MIXC, MiXzo, MLLED, MLS, Mobicel, Mobiistar, Mobiola, Mobistel, Mobo, Modecom, Mofut, Motorola, Movic, Mpman, MSI, MTC, MTN, Multilaser, MYFON, MyPhone, Myria, Mystery, MyTab, MyWigo, National, Navon, NEC, Neffos, Neomi, Netgear, NeuImage, Newgen, Newland, Newman, NewsMy, NEXBOX, Nexian, NEXON, Nextbit, NextBook, NextTab, NG Optics, NGM, Nikon, Nintendo, NOA, Noain, Nobby, Noblex, Nokia, Nomi, Nomu, Nos, Nous, NUU Mobile, Nuvo, Nvidia, NYX Mobile, O+, O2, Obi, Odys, Onda, OnePlus, Onix, ONN, Openbox, OPPO, Opsson, Orange, Orbic, Ouki, Oukitel, OUYA, Overmax, Owwo, Oysters, Oyyu, OzoneHD, Palm, Panacom, Panasonic, Pantech, PCBOX, PCD, PCD Argentina, PEAQ, Pentagram, Phicomm, Philco, Philips, Phonemax, phoneOne, Pioneer, Pixus, Ployer, Plum, PocketBook, POCO, Point of View, Polaroid, PolyPad, Polytron, Pomp, Positivo, Positivo BGH, PPTV, Prestigio, Primepad, Primux, Prixton, Proline, ProScan, Protruly, PULID, Q-Touch, Q.Bell, Qilive, QMobile, Qtek, Quantum, Quechua, Qumo, R-TV, Ramos, Ravoz, Razer, RCA Tablets, Readboy, Realme, RED, Rikomagic, RIM, Rinno, Ritmix, Ritzviva, Riviera, Roadrover, Rokit, Roku, Rombica, Ross&Moor, Rover, RoverPad, RT Project, RugGear, Runbo, Ryte, Safaricom, Sagem, Samsung, Sanei, Santin, Sanyo, Savio, Schneider, Sega, Selevision, Selfix, SEMP TCL, Sencor, Sendo, Senkatel, Senseit, Senwa, SFR, Sharp, Shift Phones, Shuttle, Siemens, Sigma, Silent Circle, Simbans, Sky, Skyworth, Smart, Smartfren, Smartisan, Softbank, Sonim, Sony, Soundmax, Soyes, Spectrum, Spice, SQOOL, Star, Starway, STF Mobile, STK, Stonex, Storex, Sugar, Sumvision, Sunstech, SunVan, Sunvell, SuperSonic, Supra, Swipe, SWISSMOBILITY, Symphony, Syrox, T-Mobile, Takara, TB Touch, TCL, TD Systems, TechniSat, TechnoTrend, TechPad, Teclast, Tecno Mobile, Tele2, Telefunken, Telego, Telenor, Telit, Tesco, Tesla, Tetratab, teXet, ThL, Thomson, TIANYU, Time2, Timovi, Tinai, TiPhone, Tolino, Tone, Tooky, Top House, Toplux, Torex, Toshiba, Touchmate, TrekStor, Trevi, Tronsmart, True, Tunisie Telecom, Turbo, Turbo-X, TurboKids, TVC, TWM, Twoe, U.S. Cellular, Ugoos, Uhans, Uhappy, Ulefone, Umax, UMIDIGI, Unihertz, Unimax, Uniscope, Unknown, Unnecto, Unonu, Unowhy, UTOK, UTStarcom, Vastking, Venso, Verizon, Vernee, Vertex, Vertu, Verykool, Vesta, Vestel, VGO TEL, Videocon, Videoweb, ViewSonic, Vinga, Vinsoc, Vipro, Vitelcom, Vivax, Vivo, Vizio, VK Mobile, VKworld, Vodacom, Vodafone, Vonino, Vontar, Vorago, Vorke, Voto, Voxtel, Voyo, Vsmart, Vsun, Vulcan, Walton, Weimei, WellcoM, Wexler, Wieppo, Wigor, Wiko, Wileyfox, Winds, Wink, Wolder, Wolfgang, Wonu, Woo, Wortmann, Woxter, X-BO, X-TIGI, X-View, Xgody, Xiaolajiao, Xiaomi, Xion, Xolo, Xoro, Xshitou, Yandex, Yarvik, Yes, Yezz, Yota, Ytone, Yu, Yuandao, Yusun, Yxtel, Zeemi, Zen, Zenek, Zfiner, Zidoo, Ziox, Zonda, Zopo, ZTE, Zuum, Zync, ZYQ, öwn

## Maintainers

- Mati Sojka: https://github.com/yagooar
- Ben Zimmer: https://github.com/benzimmer

## Contributors

Thanks a lot to the following contributors:

- Peter Gao: https://github.com/peteygao

## Contributing

1. Open an issue and explain your feature request or bug before writing any code (this can save a lot of time, both the contributor and the maintainers!)
2. Fork the project (https://github.com/podigee/device_detector/fork)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request (compare with develop)
7. When adding new data to the yaml files, please make sure to open a PR in the original project, as well (https://github.com/piwik/device-detector)
