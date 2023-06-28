## 8.0.1 2023-01-03

* Update README.md by (@ron-shinall)
* Update installation instructions by (@henrik)
* Fix deprecated File.exists? on ruby 3.2.0 by (@JNajera212)
* Fix priority country sorting bug by (@pmor)
* Update countries gem to 5.3.0 (@pmor)

## 8.0.0 2022-06-30

* Update countries gem to 5.1.0 (@pmor)
* Add deprecation warning for old priority country syntax (@pmor)
* Allow option to preserve the sort order as inputted in the `only` array of countries (@pmor)
* Remove `sort_alphabetical` dependency (@pmor)

## 7.0.0 2022-04-03

 * #200 - Drop support for Ruby 2.5 and 2.6 (@pmor)
 * #201 - Upgrade countries gem to 5.0.0 (@pmor)

## 6.1.1 2022-01-20

  * #195 - Fix deprecation warning on find_by_name (@filipemendespi)

## 6.1.0 2022-01-16

  * #190 - Upgrade to countries 4.2 (@pmor)
  * #191 - Add Rails 7 + Ruby 3.1 to build (@scudco)

## 6.0.0 2021-06-28

  * #186 - Upgrade to countries 4.0.0 (@pmor)

## 5.1.0 2021-05-18

  * #184 - Add ability to configure defaults (@p-wall)
  * Upgrade to countries 3.1.0

## 5.0.1 2021-03-08

  * #181 - Fix i18n fallback in country translations (@lavaturtle)

## 5.0.0 2021-03-04

  * #164,#172 - Remove support for EOL versions of Ruby and Ruby on Rails
    * Ruby >= 2.5, Rails >= 5.2
  * #175 - Add Rails 6.1 Support *(@andrehjr)
  * #173 - Fallback even if translations cannot be loaded (@mikepluquin)
  * #164 - Fixup travis build matrix (@olleolleolle)

## 4.0.0 2018-12-20

  * #160 - Upgrade to countries 3.0 - @gssbzn
    * https://github.com/hexorx/countries/blob/master/CHANGELOG.md#v220-yanked-and-re-released-as-300-20181217-1020-0000

## 3.1.1 2017-09-20

  * #146 - Fix value call on Rails edge (5.2+) - @ybart

## 3.1.0 2017-07-18

  * #144 - Provide a possibility to opt out of `sort_alphabetical` - @fschwahn

## 3.0.0 2016-11-25

  * #138 - Upgrade to Countries 2.0
  * #136 - Drop support for Ruby 1.9.3 as countries 2.0 no longer supports it

## 2.5.2 2015-11-10

  * #127 - Fix multi-selects - @jjballano

## 2.5.1 2015-11-10

  * #118 - Fix bad require of countries gem that caused issues if you
           already had a `Country` class

## 2.5.0 2015-11-06

  * #117 - Update countries gem to ~> v1.2.0

## 2.4.0 2015-08-25

  * #111 - Update countries gem to ~> v1.1.0

## 2.3.0 2015-08-25

  * #107,#108 - Update countries gem to ~> v1.0.0

## 2.2.0 2015-03-19

  * #101 - Update countries gem to ~> v0.11.0

## 2.1.1 2015-02-02

  * #94 - Prevent usage of countries v0.10.0 due to poor performance

## 2.1.0 2014-09-29

  * #70 - Allow custom formats for option tag text – See README.md

## 2.0.1 2014-09-18

  * #72 - Fixed `include_blank` and `prompt` in Rails 3.2
  * #75 - Raise `CountrySelect::CountryNotFound` error when given a country
    name or code that is not found in https://github.com/hexorx/countries

## 2.0.0 2014-08-10

  * Removed support for Ruby < 1.9.3
  * ISO-3166 alpha-2 codes are now on by default, stored in uppercase
    (e.g., US)
  * Localization is always on
    * The `country_select` method will always attempt to localize
      country names based on the value of `I18n.locale` via translations
      stored in the `countries` gem
  * Priority countries should now be set via the `priority_countries` option
    * The original 1.x syntax is still available
  * The list of countries can now be limited with the `only` and
    `except` options
  * Add best-guess support for country names when codes aren't provided
    in options (e.g., priority_countries)

## 1.2.0 2013-07-06

  * Country names have been synced with UTF-8 encoding to the list of
    countries on [Wikipedia's page for the ISO-3166 standard](https://en.wikipedia.org/wiki/ISO_3166-1).
    * NOTE: This could be a breaking change with some of the country
      names that have been fixed since the list was last updated.
    * For more information you can checkout all country mappings with
      `::CountrySelect::COUNTRIES`

  * You can now store your country values using the
    [ISO-3166 Alpha-2 codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
    with the `iso_codes` option. See the README.md for details.
    * This should help alleviate the problem of country names
      in ISO-3166 being changed and/or corrected.
