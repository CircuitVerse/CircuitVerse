# Changelog

## Version 2.4.0

*October 19, 2019*

- Move repository from lord/slate to slatedocs/slate
- Fix documentation to point at new repo link, thanks to [Arun](https://github.com/slash-arun), [Gustavo Gawryszewski](https://github.com/gawry), and [Daniel Korbit](https://github.com/danielkorbit)
- Update `nokogiri` to 1.10.4
- Update `ffi` in `Gemfile.lock` to fix security warnings, thanks to [Grey Baker](https://github.com/greysteil) and [jackmack](https://github.com/jakemack)
- Update `rack` to 2.0.7 in `Gemfile.lock` to fix security warnings, thanks to [Grey Baker](https://github.com/greysteil) and [jackmack](https://github.com/jakemack)
- Update middleman to `4.3` and relax constraints on middleman related gems, thanks to [jackmack](https://github.com/jakemack)
- Add sass gem, thanks to [jackmack](https://github.com/jackmack)
- Activate `asset_cache` in middleman to improve cacheability of static files, thanks to [Sam Gilman](https://github.com/thenengah)
- Update to using bundler 2 for `Gemfile.lock`, thanks to [jackmack](https://github.com/jakemack)

## Version 2.3.1

*July 5, 2018*

- Update `sprockets` in `Gemfile.lock` to fix security warnings

## Version 2.3

*July 5, 2018*

- Allows strikethrough in markdown by default.
- Upgrades jQuery to 3.2.1, thanks to [Tomi Takussaari](https://github.com/TomiTakussaari)
- Fixes invalid HTML in `layout.erb`, thanks to [Eric Scouten](https://github.com/scouten) for pointing out
- Hopefully fixes Vagrant memory issues, thanks to [Petter Blomberg](https://github.com/p-blomberg) for the suggestion
- Cleans HTML in headers before setting `document.title`, thanks to [Dan Levy](https://github.com/justsml)
- Allows trailing whitespace in markdown files, thanks to [Samuel Cousin](https://github.com/kuzyn)
- Fixes pushState/replaceState problems with scrolling not changing the document hash, thanks to [Andrey Fedorov](https://github.com/anfedorov)
- Removes some outdated examples, thanks [@al-tr](https://github.com/al-tr), [Jerome Dahdah](https://github.com/jdahdah), and [Ricardo Castro](https://github.com/mccricardo)
- Fixes `nav-padding` bug, thanks [Jerome Dahdah](https://github.com/jdahdah)
- Code style fixes thanks to [Sebastian Zaremba](https://github.com/vassyz)
- Nokogiri version bump thanks to [Grey Baker](https://github.com/greysteil)
- Fix to default `index.md` text thanks to [Nick Busey](https://github.com/NickBusey)

Thanks to everyone who contributed to this release!

## Version 2.2

*January 19, 2018*

- Fixes bugs with some non-roman languages not generating unique headers
- Adds editorconfig, thanks to [Jay Thomas](https://github.com/jaythomas)
- Adds optional `NestingUniqueHeadCounter`, thanks to [Vladimir Morozov](https://github.com/greenhost87)
- Small fixes to typos and language, thx [Emir Ribić](https://github.com/ribice), [Gregor Martynus](https://github.com/gr2m), and [Martius](https://github.com/martiuslim)!
- Adds links to Spectrum chat for questions in README and ISSUE_TEMPLATE

## Version 2.1

*October 30, 2017*

- Right-to-left text stylesheet option, thanks to [Mohammad Hossein Rabiee](https://github.com/mhrabiee)
- Fix for HTML5 history state bug, thanks to [Zach Toolson](https://github.com/ztoolson)
- Small styling changes, typo fixes, small bug fixes from [Marian Friedmann](https://github.com/rnarian), [Ben Wilhelm](https://github.com/benwilhelm), [Fouad Matin](https://github.com/fouad), [Nicolas Bonduel](https://github.com/NicolasBonduel), [Christian Oliff](https://github.com/coliff)

Thanks to everyone who submitted PRs for this version!

## Version 2.0

*July 17, 2017*

- All-new statically generated table of contents
  - Should be much faster loading and scrolling for large pages
  - Smaller Javascript file sizes
  - Avoids the problem with the last link in the ToC not ever highlighting if the section was shorter than the page
  - Fixes control-click not opening in a new page
  - Automatically updates the HTML title as you scroll
- Updated design
  - New default colors!
  - New spacings and sizes!
  - System-default typefaces, just like GitHub
- Added search input delay on large corpuses to reduce lag
- We even bumped the major version cause hey, why not?
- Various small bug fixes

Thanks to everyone who helped debug or wrote code for this version! It was a serious community effort, and I couldn't have done it alone.

## Version 1.5

*February 23, 2017*

- Add [multiple tabs per programming language](https://github.com/lord/slate/wiki/Multiple-language-tabs-per-programming-language) feature
- Upgrade Middleman to add Ruby 1.4.0 compatibility
- Switch default code highlighting color scheme to better highlight JSON
- Various small typo and bug fixes

## Version 1.4

*November 24, 2016*

- Upgrade Middleman and Rouge gems, should hopefully solve a number of bugs
- Update some links in README
- Fix broken Vagrant startup script
- Fix some problems with deploy.sh help message
- Fix bug with language tabs not hiding properly if no error
- Add `!default` to SASS variables
- Fix bug with logo margin
- Bump tested Ruby versions in .travis.yml

## Version 1.3.3

*June 11, 2016*

Documentation and example changes.

## Version 1.3.2

*February 3, 2016*

A small bugfix for slightly incorrect background colors on code samples in some cases.

## Version 1.3.1

*January 31, 2016*

A small bugfix for incorrect whitespace in code blocks.

## Version 1.3

*January 27, 2016*

We've upgraded Middleman and a number of other dependencies, which should fix quite a few bugs.

Instead of `rake build` and `rake deploy`, you should now run `bundle exec middleman build --clean` to build your server, and `./deploy.sh` to deploy it to Github Pages.

## Version 1.2

*June 20, 2015*

**Fixes:**

- Remove crash on invalid languages
- Update Tocify to scroll to the highlighted header in the Table of Contents
- Fix variable leak and update search algorithms
- Update Python examples to be valid Python
- Update gems
- More misc. bugfixes of Javascript errors
- Add Dockerfile
- Remove unused gems
- Optimize images, fonts, and generated asset files
- Add chinese font support
- Remove RedCarpet header ID patch
- Update language tabs to not disturb existing query strings

## Version 1.1

*July 27, 2014*

**Fixes:**

- Finally, a fix for the redcarpet upgrade bug

## Version 1.0

*July 2, 2014*

[View Issues](https://github.com/tripit/slate/issues?milestone=1&state=closed)

**Features:**

- Responsive designs for phones and tablets
- Started tagging versions

**Fixes:**

- Fixed 'unrecognized expression' error
- Fixed #undefined hash bug
- Fixed bug where the current language tab would be unselected
- Fixed bug where tocify wouldn't highlight the current section while searching
- Fixed bug where ids of header tags would have special characters that caused problems
- Updated layout so that pages with disabled search wouldn't load search.js
- Cleaned up Javascript
