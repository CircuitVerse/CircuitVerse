Changelog
=============

## Version 1.1.6
  * fixes parsing of multiline strings that have content on the first line. Fixes issue #3, added via PR #4 by @mgruner

## Version 1.1.5
 * added support for windows CRLF line endings. Fixes issue #2
 * Note: CRLF support is enabled if the first line ends in a CRLF and reduces performance by about 50%. Performance for files only using \n is not affected. Files not using \r\n in the first line but somewhere else in the file might trigger errors.

## Version 1.1.4
  * see 1.1.5. **Shouldn't be used**.

## Version 1.1.3

  * merged PR#1 from @christopherstat for UTF-8 support of legacy ruby versions

## Version 1.1.2
  * Made the parser thread-safe

## Version 1.1.2
  * Made the parser thread-safe

## Version 1.1.0

  * for line types only parsed once the parser returns a string instead of an array with one string

## Version 1.0.1

  * added specs
  * fixed minor parser errors

## Version 1.0.0

  * initial release
