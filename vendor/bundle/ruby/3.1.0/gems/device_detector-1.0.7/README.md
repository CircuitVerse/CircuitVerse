# DeviceDetector

[![CI](https://github.com/podigee/device_detector/workflows/CI/badge.svg)](https://github.com/podigee/device_detector/actions)

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
# Device types can be one of the following: desktop, smartphone, tablet,
# feature phone, console, tv, car browser, smart display, camera,
# portable media player, phablet, smart speaker, wearable, peripheral
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

Updated on 2022-02-17

### Bots

360Spider, Aboundexbot, Acoon, Adbeat, AddThis.com, ADMantX, ADmantX Service Fetcher, Adsbot, aHrefs Bot, Alexa Crawler, Alexa Site Audit, Amazon Bot, Amazon Route53 Health Check, Amorank Spider, Analytics SEO Crawler, ApacheBench, Applebot, AppSignalBot, Arachni, archive.org bot, ArchiveBox, Ask Jeeves, AspiegelBot, Awario, Backlink-Check.de, BacklinkCrawler, Baidu Spider, Barkrowler, BazQux Reader, BDCbot, Better Uptime Bot, BingBot, BitlyBot, Blekkobot, BLEXBot Crawler, Bloglovin, Blogtrottr, BoardReader, BoardReader Blog Indexer, Bountii Bot, BrandVerity, Browsershots, BUbiNG, Buck, BuiltWith, Butterfly Robot, Bytespider, CareerBot, Castro 2, Catchpoint, CATExplorador, ccBot crawler, CensysInspect, Charlotte, Choosito, Cincraw, CISPA Web Analyzer, Cliqzbot, CloudFlare Always Online, CloudFlare AMP Fetcher, Cloudflare Diagnostics, Cocolyzebot, Collectd, colly, CommaFeed, Comscore, ContentKing, Cookiebot, Crawldad, CSS Certificate Spider, Cốc Cốc Bot, Datadog Agent, DataForSeoBot, datagnionbot, Datanyze, Dataprovider, DataXu, Daum, Dazoobot, Discobot, Discord Bot, Domain Re-Animator Bot, Domains Project, DotBot, Dotcom Monitor, DuckDuckGo Bot, Easou Spider, eCairn-Grabber, EMail Exractor, EmailWolf, Embedly, evc-batch, ExaBot, ExactSeek Crawler, Expanse, eZ Publish Link Validator, Ezooms, Facebook External Hit, Feed Wrangler, Feedbin, FeedBurner, Feedly, Feedspot, Fever, Findxbot, Flipboard, FreshRSS, GDNP, Generic Bot, Genieo Web filter, Gigablast, Gigabot, Gluten Free Crawler, Gmail Image Proxy, Gobuster, Goo, Google Cloud Scheduler, Google Favicon, Google PageSpeed Insights, Google Partner Monitoring, Google Search Console, Google Stackdriver Monitoring, Google StoreBot, Google Structured Data Testing Tool, Googlebot, Gowikibot, Grammarly, Grapeshot, GTmetrix, Hatena Favicon, Heart Rails Capture, Heritrix, Heureka Feed, HTTPMon, httpx, HuaweiWebCatBot, HubPages, HubSpot, ICC-Crawler, ichiro, IDG/IT, IIS Site Analysis, Inktomi Slurp, inoreader, IONOS Crawler, IP-Guide Crawler, IPS Agent, JungleKeyThumbnail, K6, Kaspersky, KomodiaBot, Kouio, l9tcpid, Larbin web crawler, LCC, Let's Encrypt Validation, Lighthouse, Linespider, Linkdex Bot, LinkedIn Bot, LinkpadBot, LinkPreview, LTX71, LumtelBot, Lycos, Magpie-Crawler, MagpieRSS, Mail.Ru Bot, masscan, Mastodon Bot, Meanpath Bot, Mediatoolkit Bot, MegaIndex, MetaInspector, MetaJobBot, MicroAdBot, Mixrank Bot, MJ12 Bot, Mnogosearch, MojeekBot, Monitor.Us, MTRobot, Munin, MuscatFerret, Nagios check_http, NalezenCzBot, nbertaupete95, Neevabot, Netcraft Survey Bot, netEstate, NetLyzer FastProbe, NetResearchServer, NetSystemsResearch, Netvibes, NewsBlur, NewsGator, Nimbostratus Bot, NLCrawler, Nmap, Notify Ninja, Nutch-based Bot, Nuzzel, oBot, Octopus, Odnoklassniki Bot, Omgili bot, Openindex Spider, OpenLinkProfiler, OpenWebSpider, Orange Bot, Outbrain, PagePeeker, PageThing, PaperLiBot, parse.ly, Petal Bot, Phantomas, PHP Server Monitor, Picsearch bot, PingAdmin.Ru, Pingdom Bot, Pinterest, PiplBot, Plukkie, PocketParser, Pompos, PritTorrent, Project Resonance, PRTG Network Monitor, QuerySeekerSpider, Quora Bot, Quora Link Preview, Qwantify, Rainmeter, RamblerMail Image Proxy, Reddit Bot, Riddler, Robozilla, RocketMonitorBot, Rogerbot, ROI Hunter, RSSRadio Bot, Ryowl, SabsimBot, SafeDNSBot, Scooter, ScoutJet, Scrapy, Screaming Frog SEO Spider, ScreenerBot, security.txt scanserver, Seekport, Semantic Scholar Bot, Semrush Bot, Sensika Bot, Sentry Bot, Seobility, SEOENGBot, SEOkicks, SEOkicks-Robot, seolyt, Seoscanners.net, Serendeputy Bot, serpstatbot, Server Density, Seznam Bot, Seznam Email Proxy, Seznam Zbozi.cz, ShopAlike, Shopify Partner, ShopWiki, SilverReader, SimplePie, SISTRIX Crawler, SISTRIX Optimizer, Site24x7 Website Monitoring, Siteimprove, SitemapParser-VIPnytt, SiteSucker, Sixy.ch, Skype URI Preview, Slackbot, SMTBot, Snapchat Proxy, Sogou Spider, Soso Spider, Sparkler, Speedy, Spinn3r, Spotify, Sprinklr, Sputnik Bot, Sputnik Favicon Bot, Sputnik Image Bot, sqlmap, SSL Labs, Startpagina Linkchecker, StatusCake, Superfeedr Bot, SurdotlyBot, Survey Bot, Tarmot Gezgin, TelegramBot, The Knowledge AI, theoldreader, ThinkChaos, TinEye Crawler, Tiny Tiny RSS, TLSProbe, TraceMyFile, Trendiction Bot, Turnitin, TurnitinBot, TweetedTimes Bot, Tweetmeme Bot, Twingly Recon, Twitterbot, UkrNet Mail Proxy, UniversalFeedParser, Uptime Robot, Uptimebot, URLAppendBot, Vagabondo, Velen Public Web Crawler, Vercel Bot, VeryHip, Visual Site Mapper Crawler, VK Share Button, W3C CSS Validator, W3C I18N Checker, W3C Link Checker, W3C Markup Validation Service, W3C MobileOK Checker, W3C Unified Validator, Wappalyzer, WebbCrawler, WebDataStats, Weborama, WebPageTest, WebSitePulse, WebThumbnail, WellKnownBot, WeSEE:Search, WeViKaBot, WhatCMS, WikiDo, Willow Internet Crawler, WooRank, WordPress, Wotbox, XenForo, YaCy, Yahoo Gemini, Yahoo! Cache System, Yahoo! Japan BRW, Yahoo! Link Preview, Yahoo! Mail Proxy, Yahoo! Slurp, YaK, Yandex Bot, Yeti/Naverbot, Yottaa Site Monitor, Youdao Bot, Yourls, Yunyun Bot, Zao, Ze List, zgrab, Zookabot, ZoominfoBot, ZumBot

### Clients

115 Browser, 1Password, 2345 Browser, 2tch, 360 Browser, 360 Phone Browser, 7654 Browser, 7Star, ABrowse, Adobe Creative Cloud, Adobe Synchronizer, Aha Radio 2, AIDA64, aiohttp, Airmail, Akka HTTP, Akregator, Alexa Media Player, AliExpress, Aloha Browser, Aloha Browser Lite, Amaya, Amiga Aweb, Amiga Voyager, Amigo, Android Browser, AndroidDownloadManager, ANT Fresco, AntennaPod, ANTGalio, AOL Desktop, AOL Shield, Apple News, Apple PubSub, Arctic Fox, Aria2, Arora, Arvin, ASUS Updater, Atom, Atomic Web Browser, Audacious, Avant Browser, Avast Secure Browser, AVG Secure Browser, Avid Link, Avira Scout, AwoX, B-Line, Background Intelligent Transfer Service, Baidu Box App, Baidu Browser, Baidu Spark, Banshee, Barca, Basecamp, BashPodder, Basilisk, BathyScaphe, Battle.net, BB2C, BBC News, Be Focused, Beaker Browser, Beamrise, Beonex, BetBull, BeyondPod, Bible KJV, Binance, BingWebApp, Bitsboard, Biyubi, BlackBerry Browser, Blackboard, BlackHawk, Blitz, Blue Browser, Blue Proxy, BlueStacks, Bonsai, Bookshelf, Borealis Navigator, Bose Music, Boxee, bPod, Brave, Breaker, BriskBard, BrowseX, Browzar, Bunjalloo, Byffox, C++ REST SDK, Camino, CastBox, Castro, Castro 2, CCleaner, Centaury, CGN, ChanjetCloud, Charon, Chedot, Cheetah Browser, Cheshire, Chim Lac, ChMate, Chrome, Chrome Frame, Chrome Mobile, Chrome Mobile iOS, Chrome Update, Chrome Webview, ChromePlus, Chromium, Chromium GOST, Ciisaa, Clementine, Clovia, CM Browser, COAF SMART Citizen, Coast, Coc Coc, Colibri, CometBird, Comodo Dragon, Conkeror, CoolBrowser, CoolNovo, Copied, Cornowser, Cortana, COS Browser, Covenant Eyes, CPU-Z, Craving Explorer, Crazy Browser, CrosswalkApp, Crusta, Cunaguaro, curl, Cyberfox, DAVdroid, dbrowser, Deepnet Explorer, Deezer, deg-degan, Deledao, Delta Browser, DeskBrowse, DevCasts, DeviantArt, Dillo, DingTalk, Discord, DoggCatcher, Dolphin, Dooble, Dorado, Dot Browser, douban App, Downcast, Dr. Watson, DuckDuckGo Privacy Browser, Ecosia, Edge Update, Edge WebView, Element Browser, Elements Browser, Elinks, Embarcadero URI Client, Emby Theater, Epic, Epic Games Launcher, ESET Remote Administrator, Espial TV Browser, eToro, EUI Browser, Evernote, Evolve Podcast, eZ Browser, F-Secure SAFE, Facebook, Facebook Audience Network, Facebook Groups, Facebook Lite, Facebook Messenger, Facebook Messenger Lite, Falkon, Faraday, Faux Browser, FeedDemon, Feeddler RSS Reader, FeedR, Fennec, Firebird, Firefox, Firefox Focus, Firefox Mobile, Firefox Mobile iOS, Firefox Reality, Firefox Rocket, Fireweb, Fireweb Navigator, Flash Browser, Flast, Flipboard App, Flipp, Flock, Flow, Fluid, FlyCast, Focus Keeper, Focus Matrix, foobar2000, Foobar2000, Franz, FreeU, Gaana, Galeon, Ghostery Privacy Browser, GinxDroid Browser, Git, GitHub Desktop, Glass Browser, GlobalProtect, GNOME Web, Go-http-client, GoBrowser, GOG Galaxy, GoNative, Google Drive, Google Earth, Google Earth Pro, Google Fiber TV, Google Go, Google HTTP Java Client, Google Play Newsstand, Google Plus, Google Podcasts, Google Search App, Google Tag Manager, gPodder, GRequests, Guzzle (PHP HTTP Client), gvfs, HandBrake, Harman Browser, HasBrowser, Hawk Quick Browser, Hawk Turbo Browser, Headless Chrome, Helio, HeyTapBrowser, Hik-Connect, HiSearch, hola! Browser, HotJava, HP Smart, HTC Streaming Player, HTTP_Request2, HTTPie, Huawei Browser, Huawei Browser Mobile, IBrowse, iBrowser, iBrowser Mini, iCab, iCab Mobile, iCatcher, IceCat, IceDragon, Iceweasel, IE Mobile, IMO HD Video Calls & Chat, IMO International Calls & Chat, Instabridge, Instacast, Instagram App, Instapaper, Internet Explorer, Iridium, Iron, Iron Mobile, Isivioo, iTunes, Jakarta Commons HttpClient, JaneStyle, JaneView, Japan Browser, Jasmine, Java, JavaFX, JetBrains Omea Reader, Jig Browser, Jig Browser Plus, Jio Browser, Jungle Disk, K-meleon, K.Browser, KakaoTalk, Kapiko, Kazehakase, Keeper Password Manager, Kik, Kindle Browser, Kinza, Kiwi, Kode Browser, Kodi, Konqueror, Kylo, Lagatos Browser, Landis+Gyr AIM Browser, LG Browser, libdnf, LieBaoFast, Liferea, Light, Line, LinkedIn, Links, Live5ch, Logi Options+, Lolifox, Lotus Notes, Lovense Browser, LT Browser, LUA OpenResty NGINX, LuaKit, Lulumi, Lunascape, Lunascape Lite, Lynx, Maelstrom, MailBar, Mailbird, Mailspring, Mandarin, MAUI WAP Browser, Maxthon, mCent, Mechanize, MediaMonkey, Meizu Browser, Mercury, MetaTrader, MicroB, Microsoft Bing Search, Microsoft Edge, Microsoft Office $1, Microsoft Office Mobile, Microsoft OneDrive, Microsoft Outlook, Microsoft Store, Midori, Mikrotik Fetch, Minimo, Mint Browser, Miro, MIUI Browser, Mobicip, Mobile Safari, Mobile Silk, Monument Browser, MPlayer, mpv, Music Player Daemon, MxNitro, My World, Mypal, Naver, Navigateur Web, NCSA Mosaic, Netflix, NetFront, NetFront Life, NetNewsWire, NetPositive, Netscape, NetSurf, NewsArticle App, Newsbeuter, NewsBlur, NewsBlur Mobile App, NexPlayer, Nextcloud, NFS Browser, Nightingale, Node Fetch, Nokia Browser, Nokia OSS Browser, Nokia Ovi Browser, Notion, Nox Browser, NPR One, NTENT Browser, NTV Mobil, NuMuKi Browser, Obigo, OceanHero, Oculus Browser, Odin, Odnoklassniki, Odyssey Web Browser, Off By One, OfferUp, OhHai Browser, OkHttp, OmniWeb, ONE Browser, Opal Travel, OpenFin, Openwave Mobile Browser, Opera, Opera Devices, Opera GX, Opera Mini, Opera Mini iOS, Opera Mobile, Opera Neon, Opera News, Opera Next, Opera Touch, Oppo Browser, Orca, Ordissimo, Oregano, Origin In-Game Overlay, Origyn Web Browser, Otter Browser, Outlook Express, Overcast, Paint by Number, Pale Moon, Palm Blazer, Palm Pre, Palm WebPro, Palmscape, Pandora, Papers, Peeps dBrowser, Perfect Browser, Perl, Perl REST::Client, Phantom Browser, Phoenix, Phoenix Browser, Pic Collage, Pinterest, Player FM, PlayFree Browser, Pocket Casts, Podbean, Podcast & Radio Addict, Podcast Republic, Podcaster, Podcasts, Podcat, Podcatcher Deluxe, Podimo, Podkicker$1, Polaris, Polarity, PolyBrowser, Polypane, Postbox, Postman Desktop, PowerShell, PritTorrent, PrivacyWall, Procast, PSI Secure Browser, Puffin, Pulp, Python Requests, Python urllib, Q-municate, Qazweb, qBittorrent, QQ Browser, QQ Browser Lite, QQ Browser Mini, QQMusic, QtWebEngine, Quark, Quick Search TV, QuickCast, QuickTime, QuiteRSS, QupZilla, Qutebrowser, Qwant Mobile, RadioPublic, Raindrop.io, Rambox Pro, Rave Social, Razer Synapse, RDDocuments, ReactorNetty, ReadKit, Realme Browser, Reeder, Rekonq, rekordbox, REST Client for Ruby, RestSharp, Roblox, RoboForm, Rocket Chat, RockMelt, RSS Bandit, RSS Junkie, RSSOwl, RSSRadio, Safari, Safe Exam Browser, Sailfish Browser, SalamWeb, Samsung Browser, Samsung Magician, ScalaJ HTTP, SeaMonkey, Secure Browser, Seewo Browser, SEMC-Browser, Seraphic Sraf, Seznam Browser, SFive, Shiira, Shopee, ShowMe, SimpleBrowser, Sina Weibo, Siri, Sizzy, Skyeng Teachers, Skyfire, Skype, Skype for Business, Slack, Sleipnir, Slimjet, Smart Lenovo Browser, Smooz, Snapchat, Snowshoe, Sogou Explorer, Sogou Mobile Browser, SogouSearch App, Songbird, SONOS, Sony Media Go, SP Browser, Spectre Browser, Splash, SPORT1, Sputnik Browser, Stagefright, Stampy Browser, Stargon, START Internet Browser, Steam In-Game Overlay, Streamlabs OBS, Streamy, Strimio, Stringer, SubStream, Sunrise, Super Fast Browser, SuperBird, surf, Sushi Browser, Swiftfox, Swoot, T+Browser, T-Browser, t-online.de Browser, Tao Browser, Teams, TenFourFox, Tenta Browser, The Bat!, The Wall Street Journal, Theyub, Thunder, Thunderbird, tieba, TikTok, Tizen Browser, ToGate, TopBuzz, TradingView, TuneIn Radio, TuneIn Radio Pro, Tungsten, TV Bro, TVirl, TweakStyle, twinkle, Twitter, Twitterrific, U-Cursos, UBrowser, UC Browser, UC Browser HD, UC Browser Mini, UC Browser Turbo, uclient-fetch, Uconnect LIVE, Unibox, Unirest for Java, UnityPlayer, UR Browser, urlgrabber (yum), uTorrent, Uzbl, Venus Browser, Viber, Vision Mobile Browser, Visual Studio Code, Vivaldi, vivo Browser, VLC, VMware AirWatch, Vuhuv, Waterfox, Wattpad, Wayback Machine, Wear Internet Browser, Web Explorer, WebDAV, WebPositive, WeChat, WeChat Share Extension, WeTab Browser, Wget, WH Questions, Whale Browser, WhatsApp, Whisper, Winamp, Windows CryptoAPI, Windows Delivery Optimization, Windows Mail, Windows Media Player, Windows Push Notification Services, Windows Update Agent, WinHttp WinHttpRequest, Wireshark, Wirtschafts Woche, Word Cookies!, wOSBrowser, WWW-Mechanize, XBMC, Xiino, xStand, Xvast, Y8 Browser, Yaani Browser, Yahoo! Japan, Yahoo! Japan Browser, YakYak, Yandex, Yandex Browser, Yandex Browser Lite, Yelp Mobile, Yolo Browser, YouTube, Zalo, ZEPETO, Zetakey, Zoho Chat, Zvu

### Devices

2E, 360, 3GNET, 3GO, 3Q, 4Good, 4ife, 7 Mobile, 8848, A1, Accent, Ace, Acer, Acteck, Adronix, Advan, Advance, AfriOne, AG Mobile, AGM, AIDATA, Ainol, Airness, AIRON, Airties, AIS, Aiuto, Aiwa, Akai, AKIRA, Alba, Alcatel, Alcor, ALDI NORD, ALDI SÜD, Alfawise, Aligator, AllCall, AllDocube, Allview, Allwinner, Alps, Altech UEC, Altice, altron, Amazon, AMCV, AMGOO, Amigoo, Amino, Amoi, Andowl, Anker, Anry, ANS, AOC, Aocos, AOpen, Aoson, AOYODKG, Apple, Archos, Arian Space, Ark, ArmPhone, Arnova, ARRIS, Artel, Artizlee, ArtLine, Asano, Asanzo, Ask, Aspera, Assistant, Astro, Asus, AT&T, Atom, Atvio, Audiovox, AURIS, Avenzo, AVH, Avvio, Awow, Axioo, Axxion, Azumi Mobile, BangOlufsen, Barnes & Noble, BB Mobile, BBK, BDF, BDQ, Becker, Beeline, Beelink, Beetel, Beista, Bellphone, Benco, BenQ, BenQ-Siemens, Benzo, Beyond, Bezkam, BGH, Bigben, BIHEE, BilimLand, Billion, BioRugged, Bird, Bitel, Bitmore, Bkav, Black Bear, Black Fox, Blackview, Blaupunkt, Bleck, Blloc, Blow, Blu, Bluboo, Bluebird, Bluedot, Bluegood, Bluewave, BMAX, Bmobile, Bobarry, bogo, Boway, bq, Brandt, Bravis, BrightSign, Brondi, BS Mobile, Bubblegum, Bundy, Bush, CAGI, Camfone, Canal Digital, Capitel, Captiva, Carrefour, Casio, Casper, Cat, Cavion, Celcus, Celkon, Cell-C, CellAllure, Cellution, Centric, CG Mobile, CGV, Changhong, Cherry Mobile, Chico Mobile, China Mobile, Chuwi, Claresta, Clarmin, Clementoni, Cloud, Cloudfone, Cloudpad, Clout, CnM, Cobalt, Coby Kyros, Colors, Comio, Compal, ComTrade Tesla, Concord, ConCorde, Condor, Connectce, Connex, Conquest, Contixo, Coolpad, CORN, Cosmote, Covia, Cowon, CreNova, Crescent, Cricket, Crius Mea, Crony, Crosscall, Cube, CUBOT, CVTE, Cyrus, Daewoo, Danew, Datalogic, Datamini, Datang, Datawind, Datsun, Dazen, Dbtel, Dell, Denver, Desay, DeWalt, DEXP, DF, Dialog, Dicam, Digi, Digicel, DIGIFORS, Digihome, Digiland, Digma, DING DING, DISH, Ditecma, Diva, Divisat, DIXON, DMM, DNS, DoCoMo, Doffler, Dolamee, Doogee, Doopro, Doov, Dopod, Doro, Dragon Touch, Dreamgate, Droxio, Dune HD, DUNNS Mobile, E-Boda, E-Ceros, E-tel, Eagle, Easypix, EBEST, Echo Mobiles, ECON, ECS, EE, Einstein, EKO, Eks Mobility, EKT, ELARI, Electroneum, ELECTRONIA, Elekta, Element, Elenberg, Elephone, Eltex, Ematic, Energizer, Energy Sistem, Engel, Enot, Epik One, Epson, Ergo, Ericsson, Ericy, Erisson, Essential, Essentielb, eSTAR, Eton, eTouch, Etuline, Eurocase, Eurostar, Evercoss, Evertek, Evolio, Evolveo, Evoo, EvroMedia, EWIS, EXCEED, Exmart, ExMobile, EXO, Explay, Extrem, Ezio, Ezze, F&U, F150, F2 Mobile, Facebook, Fairphone, Famoco, Fantec, FaRao Pro, FarEasTone, Fengxiang, FEONAL, Fero, FiGi, FiGO, FiiO, FinePower, Finlux, FireFly Mobile, FISE, Fly, FLYCAT, FMT, FNB, FNF, Fondi, Fonos, FORME, Formuler, Forstar, Fortis, Four Mobile, Fourel, Foxconn, Freetel, Fuego, Fujitsu, Fusion5, G-TiDE, G-Touch, Galaxy Innovations, Garmin-Asus, Gateway, Gemini, General Mobile, Genesis, GEOFOX, Geotel, Geotex, GFive, Ghia, Ghong, Ghost, Gigabyte, Gigaset, Gini, Ginzzu, Gionee, Globex, Glofiish, GLONYX, GLX, GOCLEVER, Gocomma, GoGEN, Gol Mobile, Goly, Gome, GoMobile, Google, Goophone, Gooweel, Gplus, Gradiente, Grape, Gree, Greentel, Gresso, Gretel, Grundig, Gtel, H96, Hafury, Haier, HannSpree, Hardkernel, Hasee, Helio, HERO, Hezire, Hi, Hi-Level, High Q, Highscreen, HiMax, Hipstreet, Hisense, Hitachi, Hitech, Hoffmann, Hometech, Homtom, Honeywell, Hoozo, Horizon, Horizont, Hosin, Hot Pepper, Hotel, Hotwav, How, HP, HTC, Huadoo, Huavi, Huawei, Humax, Hurricane, Huskee, Hyundai, Hyve, i-Cherry, i-Joy, i-mate, i-mobile, iBall, iBerry, iBrit, IconBIT, iData, iDroid, iGet, iHunt, Ikea, IKI Mobile, iKoMo, iKon, IKU Mobile, iLA, iLife, iMan, iMars, IMO Mobile, Impression, INCAR, Inch, Inco, iNew, Infinix, InFocus, InfoKit, Inkti, InnJoo, Innos, Innostream, Inoi, INQ, Insignia, INSYS, Intek, Intex, Invens, Inverto, Invin, iOcean, iOutdoor, iPro, iQ&T, IQM, IRA, Irbis, Iris, iRola, iRulu, iSafe Mobile, iSWAG, IT, iTel, iTruck, IUNI, iVA, iView, iVooMi, ivvi, iZotron, JAY-Tech, Jeka, Jesy, JFone, Jiake, Jiayu, Jinga, Jivi, JKL, Jolla, Juniper Systems, Just5, JVC, K-Touch, Kaan, Kaiomy, Kalley, Kanji, Karbonn, Kata, KATV1, Kazam, Kazuna, KDDI, Kempler & Strauss, Keneksi, Kenxinda, Kiano, Kingsun, KINGZONE, Kiowa, Kivi, Klipad, Kocaso, Kodak, Kogan, Komu, Konka, Konrow, Koobee, Koolnee, Kooper, KOPO, Koridy, KREZ, KRIP, KRONO, Krüger&Matz, KT-Tech, KUBO, Kuliao, Kult, Kumai, Kurio, Kvant, Kyocera, Kyowon, Kzen, L-Max, LAIQ, Land Rover, Landvo, Lanix, Lark, Laurus, Lava, LCT, Le Pan, Leader Phone, Leagoo, Leben, Ledstar, LeEco, Leff, LEMFO, Lemhoov, Lenco, Lenovo, Leotec, Lephone, Lesia, Lexand, Lexibook, LG, Liberton, Lifemaxx, Lingwin, Linnex, Linsar, Loewe, Logic, Logicom, Loview, LT Mobile, Lumigon, Lumus, Luna, Luxor, LYF, M-Horse, M-Tech, M.T.T., M4tel, MAC AUDIO, Macoox, Mafe, Magicsee, Magnus, Majestic, Malata, Manhattan, Mann, Manta Multimedia, Mantra, Mara, Masstel, Matrix, Maxcom, Maximus, Maxtron, MAXVI, Maxwest, Maze, Maze Speed, MBOX, MDC Store, MDTV, meanIT, Mecer, Mecool, Mediacom, MediaTek, Medion, MEEG, MegaFon, Meitu, Meizu, Melrose, Memup, Metz, MEU, MicroMax, Microsoft, Microtech, Minix, Mintt, Mio, Mione, Miray, Mito, Mitsubishi, Mitsui, MIVO, MIXC, MiXzo, MLLED, MLS, Mobicel, MobiIoT, Mobiistar, Mobiola, Mobistel, MobiWire, Mobo, Modecom, Mofut, Motorola, Movic, mPhone, Mpman, MSI, MStar, MTC, MTN, Multilaser, MYFON, MyGica, Mymaga, MyPhone, Myria, Myros, Mystery, MyTab, MyWigo, Nabi, Naomi Phone, National, Navcity, Navitech, Navitel, Navon, NavRoad, NEC, Necnot, Neffos, Neomi, Neon IQ, Netgear, NeuImage, New Balance, Newgen, Newland, Newman, Newsday, NewsMy, NEXBOX, Nexian, NEXON, Nextbit, NextBook, NextTab, NG Optics, NGM, Nikon, Nintendo, NOA, Noain, Nobby, Noblex, NOBUX, NOGA, Nokia, Nomi, Nomu, Nordmende, NorthTech, Nos, Nous, Novex, NuAns, Nubia, NUU Mobile, Nuvo, Nvidia, NYX Mobile, O+, O2, Oale, OASYS, Obabox, Obi, Oculus, Odys, OINOM, Ok, Okapia, OKSI, OKWU, Onda, OnePlus, Onix, ONN, ONYX BOOX, OpelMobile, Openbox, OPPO, Opsson, Orange, Orbic, Orbita, Ordissimo, Ouki, Oukitel, OUYA, Overmax, Ovvi, Owwo, Oysters, Oyyu, OzoneHD, P-UP, Packard Bell, Paladin, Palm, Panacom, Panasonic, Pantech, Parrot Mobile, PCBOX, PCD, PCD Argentina, PEAQ, Pendoo, Pentagram, Perfeo, Phicomm, Philco, Philips, Phonemax, phoneOne, Pico, Pioneer, PiPO, Pixela, Pixelphone, Pixus, Planet Computers, Ployer, Plum, Pluzz, PocketBook, POCO, Point of View, Polar, PolarLine, Polaroid, Polestar, PolyPad, Polytron, Pomp, Poppox, POPTEL, Porsche, Positivo, Positivo BGH, PPTV, Premio, Prestigio, Primepad, Primux, Prixton, PROFiLO, Proline, Prology, ProScan, Protruly, ProVision, PULID, Q-Box, Q-Touch, Q.Bell, Qilive, QMobile, Qnet Mobile, QTECH, Qtek, Quantum, Qubo, Quechua, Qumo, R-TV, Rakuten, Ramos, Raspberry, Ravoz, Razer, RCA Tablets, Reach, Readboy, Realme, RED, Redfox, Reeder, REGAL, Remdun, Retroid Pocket, Revo, Rikomagic, RIM, Rinno, Ritmix, Ritzviva, Riviera, Rivo, Roadrover, Rokit, Roku, Rombica, Ross&Moor, Rover, RoverPad, RoyQueen, RT Project, RugGear, Ruio, Runbo, Ryte, S-TELL, Saba, Safaricom, Sagem, Saiet, Salora, Samsung, Sanei, Sansui, Santin, Sanyo, Savio, SCBC, Schneider, Seatel, Seeken, SEG, Sega, Selecline, Selenga, Selevision, Selfix, SEMP TCL, Sencor, Sendo, Senkatel, Senseit, Senwa, Seuic, SFR, Sharp, Shift Phones, Shivaki, Shtrikh-M, Shuttle, Sico, Siemens, Sigma, Silelis, Silent Circle, Simbans, Simply, Singtech, Siragon, Sirin labs, SKG, Sky, Skyworth, Smadl, Smailo, Smart, Smart Electronic, Smartab, SmartBook, SMARTEC, Smartfren, Smartisan, Smarty, Smooth Mobile, Smotreshka, Softbank, Soho Style, SOLE, SOLO, Solone, Sonim, SONOS, Sony, Soundmax, Soyes, Spark, SPC, Spectralink, Spectrum, Spice, Sprint, SQOOL, Star, Starlight, Starmobile, Starway, Starwind, STF Mobile, STG Telecom, STK, Stonex, Storex, StrawBerry, STRONG, Stylo, Subor, Sugar, Sumvision, Sunmi, Sunny, Sunstech, SunVan, Sunvell, SUNWIND, SuperSonic, SuperTab, Supra, Suzuki, Swipe, SWISSMOBILITY, Swisstone, SWTV, Symphony, Syrox, T-Mobile, TAG Tech, Taiga System, Takara, Tambo, Tanix, TB Touch, TCL, TD Systems, Technicolor, Technika, TechniSat, TechnoTrend, TechPad, Techwood, Teclast, Tecno Mobile, TEENO, Teknosa, Tele2, Telefunken, Telego, Telenor, Telia, Telit, Telpo, Tesco, Tesla, Tetratab, teXet, ThL, Thomson, Thuraya, TIANYU, Tigers, Time2, Timovi, Tinai, Tinmo, TiPhone, TiVo, TOKYO, Tolino, Tone, Tooky, Top House, Topelotek, Toplux, Topway, Torex, TOSCIDO, Toshiba, Touchmate, Transpeed, TrekStor, Trevi, Trident, Trifone, Trio, Tronsmart, True, True Slim, TTEC, TuCEL, Tunisie Telecom, Turbo, Turbo-X, TurboKids, TurboPad, Turkcell, TVC, TWM, Twoe, TWZ, Tymes, Türk Telekom, U.S. Cellular, Ugoos, Uhans, Uhappy, Ulefone, Umax, UMIDIGI, Unihertz, Unimax, Uniscope, UNIWA, Unknown, Unnecto, Unonu, Unowhy, Urovo, UTime, UTOK, UTStarcom, UZ Mobile, v-mobile, VAIO, Vankyo, Vargo, Vastking, VAVA, VC, Vega, Venso, Venturer, VEON, Verico, Verizon, Vernee, Vertex, Vertu, Verykool, Vesta, Vestel, Vexia, VGO TEL, Videocon, Videoweb, ViewSonic, Vinabox, Vinga, Vinsoc, Vipro, Virzo, Vision Touch, Vitelcom, Viumee, Vivax, Vivo, VIWA, Vizio, VK Mobile, VKworld, Vodacom, Vodafone, Vonino, Vontar, Vorago, Vorke, Voto, VOX, Voxtel, Voyo, Vsmart, Vsun, Vulcan, VVETIME, Walton, WE, Weimei, WellcoM, WELLINGTON, Western Digital, Westpoint, Wexler, Wieppo, Wigor, Wiko, Wileyfox, Winds, Wink, Winmax, Winnovo, Wintouch, Wiseasy, WIWA, Wizz, Wolder, Wolfgang, Wolki, Wonu, Woo, Wortmann, Woxter, X-BO, X-TIGI, X-View, X.Vision, XGIMI, Xgody, Xiaolajiao, Xiaomi, Xion, Xolo, Xoro, Xshitou, Xtouch, Xtratech, Yandex, Yarvik, YASIN, Yes, Yezz, Yoka TV, Yota, YOTOPT, Ytone, Yu, Yuandao, YUHO, Yuno, Yusun, Yxtel, Zaith, Zatec, Zebra, Zeemi, Zen, Zenek, Zentality, Zfiner, ZH&K, Zidoo, ZIFRO, Ziox, Zonda, Zopo, ZTE, Zuum, Zync, ZYQ, Zyrex, öwn

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
