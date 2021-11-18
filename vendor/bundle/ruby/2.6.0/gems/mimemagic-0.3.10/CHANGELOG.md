# Changelog

## Unreleased

### Breaking Changes

## 0.3.7 (2021-03-25)

You will now need to ensure you have a copy of the fd.o shared MIME
types information available before installing this gem. More details
can be found in the readme.

### Added

None

### Fixed

None

## 0.3.10

* Improve the development/test experience (@coldnebo, @kachick)

* Ensure the gem works in environments with gem caching (@haines)

* Add support for MacPorts installed dependencies (@brlanier)

* Allow using a dummy XML file in cases where the gem is just a transient
  dependency. (@Scharrels)
  
## 0.3.9 (2021-03-25)

* Resolve issues parsing the version of freedesktop.org.xml shipped with
  Ubuntu Trusty.

* Reintroduce overlays, since it seems at least some people were using
  them.
  
* Make Rake a runtime dependency.

* Fix the test suite.
## 0.3.8 (2021-03-25)

Relax the dependency on Nokogiri to something less specific in order
to avoid conflicting with other dependencies in people's applications.

## 0.3.7 (2021-03-25)

Add a dependency on having a preinstalled version of the fd.o shared
MIME types info to resolve licensing concerns, and allow this gem to
remain MIT licensed.

See the readme for details on ensuring you have a copy of the database
available at install time.
## 0.3.6 (2021-03-23)

Yanked release, relicensing to GPL due to licensing concerns.
## 0.3.5 (2020-05-04)

Mimetype extensions are now ordered by freedesktop.org's priority

## 0.3.4 (2020-01-28)

Added frozen string literal comments

## 0.3.3 (2018-12-20)

Upgrade to shared-mime-info-1.10

## 0.3.2 (2016-08-02)

### Breaking Changes

None

### Added

- [#37](https://github.com/minad/mimemagic/pull/37)
  A convenient way to get all possible mime types by magic

### Fixed

- [#40](https://github.com/minad/mimemagic/pull/40),
  [#41](https://github.com/minad/mimemagic/pull/41)
  Performance improvements
- [#38](https://github.com/minad/mimemagic/pull/38)
  Updated to shared-mime-info 1.6

## 0.3.1 (2016-01-04)

No release notes yet. Contributions welcome.

## 0.3.0 (2015-03-25)

No release notes yet. Contributions welcome.

## 0.2.1 (2013-07-29)

No release notes yet. Contributions welcome.

## 0.2.0 (2012-10-19)

No release notes yet. Contributions welcome.

## 0.1.9 (2012-09-20)

No release notes yet. Contributions welcome.

## 0.1.8 (2009-05-08)

No release notes yet. Contributions welcome.

## 0.1.7 (2009-05-08)

No release notes yet. Contributions welcome.

## 0.1.5 (2009-05-08)

No release notes yet. Contributions welcome.

## 0.1.4 (2009-05-08)

No release notes yet. Contributions welcome.

## 0.1.3 (2009-05-08)

No release notes yet. Contributions welcome.

## 0.1.2 (2009-05-08)

No release notes yet. Contributions welcome.

## 0.1.1 (2009-05-08)

No release notes yet. Contributions welcome.


