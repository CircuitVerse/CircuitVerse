# 4.6.1 (2021-08-19)
* Fix bug in IEdriver caused by bad formatting in recent release

# 4.6.0 (2021-02-26)
* Update `Edgedriver` naming to support Selenium 4 beta (([#206](https://github.com/titusfortner/webdrivers/pull/206))

# 4.5.0 (2021-01-19)
* Improve format of README usage section. Thanks, [okuramasafumi](https://github.com/okuramasafumi)!
* `chromedriver` - Add support for Apple M1 specific builds ([#193](https://github.com/titusfortner/webdrivers/pull/193)). Thanks, [MichaelHoste](https://github.com/MichaelHoste)!
* `msedgedriver` - Add support for Apple M1 specific builds.
* `msedgedriver` - Added automatic selection of 32-bit vs 64-bit builds on Windows and WSLv1.  
* When using this gem in WSLv2, Chrome installed on the Linux filesystem will be automatically used ([#196](https://github.com/titusfortner/webdrivers/pull/196)). 
  WSLv1 continues to automatically use Chrome from the Windows filesystem though. Thanks, [fabioxgn](https://github.com/fabioxgn)!
  * We'll aim to make the behavior consistent in a future release.

### 4.4.2 (2020-12-29)
* Use new powershell if available to enhance WSL support ([#176](https://github.com/titusfortner/webdrivers/issues/176), 
  [#186](https://github.com/titusfortner/webdrivers/pull/186)). Thanks, [G-Rath](https://github.com/G-Rath) and 
  [131](https://github.com/131)!
* Update rubocop version (development dependency only) ([#178](https://github.com/titusfortner/webdrivers/pull/178)).
  Thanks, [utkarsh2102](https://github.com/utkarsh2102)!
* Replace `git ls-files` with `dir` in the gemspec for better Debian support ([#179](https://github.com/titusfortner/webdrivers/pull/179),
  [#184](https://github.com/titusfortner/webdrivers/issues/184)).
  Thanks again, [utkarsh2102](https://github.com/utkarsh2102)!
* Update README with `require: false` when adding gem to Gemfile ([#183](https://github.com/titusfortner/webdrivers/pull/183)).
* Make WSL detection more generic ([#187](https://github.com/titusfortner/webdrivers/pull/187)).
  [rbclark](https://github.com/rbclark)!
  
### 4.4.1 (2020-06-01)
* Do not include binstubs used for troubleshooting only. Fixes [#174](https://github.com/titusfortner/webdrivers/issues/174).

### 4.4.0 (2020-05-31)
* Implement support for `chromedriver` in Windows Subsystem for Linux (WSL) v1 ([#172](https://github.com/titusfortner/webdrivers/issues/172)). 
  Thanks, [G-Rath](https://github.com/G-Rath)!
* Chrome/Edgedriver - Fix [#171](https://github.com/titusfortner/webdrivers/issues/171) by making sure the cached
driver build version matches the browser build version before using it.
* Chrome/Edgedriver - Driver version check now matches the driver and browser `major.minor.build` versions instead of just 
the major version to be fully compliant with the `chromedriver` version selection
[document](https://chromedriver.chromium.org/downloads/version-selection).

### 4.3.0 (2020-04-14)
* Add support for Microsoft Edge (Chromium) stable
* Drop support for Ruby < 2.4.0

### 4.2.0 (2019-12-27)
* Add support for Microsoft Edge (Chromium) Beta releases ([#155](https://github.com/titusfortner/webdrivers/pull/155))
* Use tilde expansion to resolve user's home directory ([#166](https://github.com/titusfortner/webdrivers/pull/161))
* Add support for Chromium installed using Snap on Ubuntu ([#163](https://github.com/titusfortner/webdrivers/pull/163)). Thanks Tietew!

### 4.1.3 (2019-10-07)
* Require rubyzip version 1.3.0 or higher to fix [rubyzip#403](https://github.com/rubyzip/rubyzip/pull/403). Thanks rhymes! ([#153](https://github.com/titusfortner/webdrivers/pull/153))
* Fix a bug where the file deletion confirmation was printed even when there were no files to delete.

### 4.1.2 (2019-07-29)
* Fix a bug related to raising `BrowserNotFound`.

### 4.1.1 (2019-07-18)
* Raise `BrowserNotFound` if Chrome and Edge binary are not found (issue [#144](https://github.com/titusfortner/webdrivers/issues/144)).

### 4.1.0 (2019-07-03)
* Add support for `msedgedriver` (issue [#93](https://github.com/titusfortner/webdrivers/issues/93))
* Allow users to provide a custom binary path via `WD_CHROME_PATH` 
and `WD_EDGE_CHROME_ATH` environment variables (issues #[137](https://github.com/titusfortner/webdrivers/issues/137) 
and [#93](https://github.com/titusfortner/webdrivers/issues/93))
* Fix a bug where the user given Chrome binary path via `Selenium::WebDriver::Chrome.path` 
was not properly escaped (issue [#139](https://github.com/titusfortner/webdrivers/issues/139))
* Fix miscellaneous code warnings.
* ~~**Announcement**: As of 06/21/2019, `heroku-buildpack-google-chrome` 
no longer requires a [workaround](https://github.com/titusfortner/webdrivers/wiki/Heroku-buildpack-google-chrome) 
to work with this gem. See [heroku-buildpack-google-chrome#73](https://github.com/heroku/heroku-buildpack-google-chrome/pull/73) 
for more information.~~

### 4.0.1 (2019-06-12)
* Cache time now defaults to 86,400 Seconds (24 hours). Please note the special exception for `chromedriver` in the [README](https://github.com/titusfortner/webdrivers#special-exception-for-chromedriver-and-msedgedriver) (issue [#132](https://github.com/titusfortner/webdrivers/issues/132))
* Properly escape Chrome binary path when using JRuby on Windows (issue [#130](https://github.com/titusfortner/webdrivers/issues/130))
* Allow use of `selenium-webdriver` v4 (pre-releases only)

### 4.0.0 (2019-05-28)

No changes since rc2. Please report any issues [here](https://github.com/titusfortner/webdrivers/issues)
or join us in the `#webdrivers-gem` channel on [Slack](https://seleniumhq.herokuapp.com/) if you 
have questions.

### 4.0.0.rc2 (2019-05-21)
* Fix a bug with `WD_CACHE_TIME` when using the rake tasks (issue [#123](https://github.com/titusfortner/webdrivers/pull/123))

### 4.0.0.rc1 (2019-05-20)
* Locate Chrome binary the same way as chromedriver to ensure the correct browser version is 
obtained by default (issue [#45](https://github.com/titusfortner/webdrivers/issues/45))
* Add rake tasks for update, remove and version 
(issues [#28](https://github.com/titusfortner/webdrivers/issues/28) 
[#77](https://github.com/titusfortner/webdrivers/issues/77))
* Removed all deprecated code

### 3.9.4 (2019-05-20)
* Fix bug from bug fix that warned users about setting cache time when it was already set (issue [#118](https://github.com/titusfortner/webdrivers/pull/118)) 
* Make #base_url public for easier mocking (issue [#109](https://github.com/titusfortner/webdrivers/issues/109))

### 3.9.3 (2019-05-17)
* Fix the bug that warned users about setting cache time when it was already set 
([#118](https://github.com/titusfortner/webdrivers/pull/118), thanks Eduardo Gutierrez)

### 3.9.2 (2019-05-14)
* Allow webdrivers to handle network mocking ([#116](https://github.com/titusfortner/webdrivers/pull/116))
* Fix a Windows specific bug when decompressing the driver packages 
([#114](https://github.com/titusfortner/webdrivers/pull/114))

### 3.9.1 (2019-05-09)
* Fix bug throwing nil warnings (issue #107)
* Fix bug preventing running on older versions of Selenium

### 3.9.0 (2019-05-07)
* Make public methods more obvious and deprecate unnecessary methods (issue #36)
* Allow geckodriver binaries to be downloaded directly (issue #30)
* Allow drivers to be cached to reduce unnecessary network calls (issue #29)
* MSWebdriver class is removed as no longer supported 
* Refactored to minimize network calls (issue #80)
* Fix warnings about instance variables not initialized
* Add support for managing specific drivers (issue #95)

### 3.8.1 (2019-05-04)
* Downloads chromedriver with direct URL instead of parsing the downloads page
* Raises exception if version of Chrome does not have a known version of the driver (issue #79)
* Fixed bug warning of non-initialized variables (issue #62)
* Fixed bug with threads/processes colliding by downloading to temp files
* Fixed bug for file locking issue on Windows

### 3.8.0 (2019-04-17)
* Add support for `selenium-webdriver` v4. See [#69](https://github.com/titusfortner/webdrivers/pull/69).
* Remove dependency on `net_http_ssl_fix` gem. `Webdrivers.net_http_ssl_fix` now raises an exception and 
points to other solutions. See [#60](https://github.com/titusfortner/webdrivers/pull/60) and 
[#68](https://github.com/titusfortner/webdrivers/pull/68) (thanks Samuel Williams & Maik Arnold).

### 3.7.2 (2019-04-01)
* Fix bugs in methods that retrieve Chrome/Chromium version. 
See [#43](https://github.com/titusfortner/webdrivers/pull/43) 
and [#52](https://github.com/titusfortner/webdrivers/issues/52) (Thanks Ochko). 
* Add workaround for a Jruby bug when retrieving Chrome version on Windows. 
See [#41](https://github.com/titusfortner/webdrivers/issues/41).
* Update README with more information.

### 3.7.1 (2019-03-25)
* Use `Selenium::WebDriver::Chrome#path` to check for a user given browser executable 
before defaulting to Google Chrome. Addresses [#38](https://github.com/titusfortner/webdrivers/issues/38).
* Download `chromedriver` v2.46 if Chrome/Chromium version is less than 70.

### 3.7.0 (2019-03-19)

* `chromedriver` version now matches the installed Chrome version. 
See [#32](https://github.com/titusfortner/webdrivers/pull/32).

### 3.6.0 (2018-12-30)

* Put net_http_ssl_fix inside a toggle since it can cause other issues

### 3.5.2 (2018-12-16)

* Use net_http_ssl_fix to address Net::HTTP issues on windows

### 3.5.1 (2018-12-16)

### 3.5.0 (2018-12-15)

### 3.5.0.beta1 (2018-12-15)

* Allow version to be specified

### 3.4.3 (2018-10-22)

* Fix bug with JRuby and geckodriver (thanks twalpole)

### 3.4.2 (2018-10-15)

* Use chromedriver latest version 

### 3.4.1 (2018-09-17)

* Hardcode latest chromedriver version to 2.42 until we figure out chromedriver 70 

### 3.4.0 (2018-09-07)

* Allow public access to `#install_dir` and `#binary`
* Allow user to set the default download directory
* Improve version comparisons with use of `Gem::Version` 

### 3.3.3 (2018-08-14)

* Fix Geckodriver since Github changed its html again

### 3.3.2 (2018-05-04)

* Fix bug with IEDriver versioning (Thanks Aleksei Gusev)

### 3.3.1 (2018-05-04)

* Fix bug with MSWebdriver to fetch the correct driver instead of latest (Thanks kapoorlakshya) 

### 3.3.0 (2018-04-29)

* Ensures downloading correct MSWebdriver version (Thanks kapoorlakshya) 

### 3.2.4 (2017-01-04)

* Improve error message when unable to find the latest driver

### 3.2.3 (2017-12-12)

* Fixed bug with finding geckodriver on updated Github release pages

### 3.2.2 (2017-11-20)

* Fixed bug in `#untargz_file` (thanks Jake Goulding)

### 3.2.1 (2017-09-06)

* Fixed Proxy support so it actually works (thanks Cheezy) 

### 3.2.0 (2017-08-21)

* Implemented Proxy support 

### 3.1.0 (2017-08-21)

* Implemented Logging functionality 

### 3.0.1 (2017-08-18)

* Create ~/.webdrivers directory if doesn't already exist 

### 3.0.0 (2017-08-17)

* Removes unnecessary downloads 

### 3.0.0.beta3 (2017-08-17)

* Supports Windows
* Supports mswebdriver and iedriver

### 3.0.0.beta2 (2017-08-16)

* Supports geckodriver on Mac and Linux

### 3.0.0.beta1 (2017-08-15)

* Complete Rewrite of 2.x
* Implemented with Monkey Patch not Shims
* Supports chromedriver on Mac and Linux
