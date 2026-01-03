# Changelog

<!--
Prefix your message with one of the following:

- [Added] for new features.
- [Changed] for changes in existing functionality.
- [Deprecated] for soon-to-be removed features.
- [Removed] for now removed features.
- [Fixed] for any bug fixes.
- [Security] in case of vulnerabilities.
-->

## v0.4.1 - 2024-01-03

- [Fixed] Fix partial matching when not using `*`.

## v0.4.0 - 2022-12-05

- [Changed] `Glob::Query` has been renamed to `Glob::Object`.
- [Added] Allow adding new keys with `glob.set(path, value)`.

## v0.3.1 - 2022-09-01

- [Fixed] Handle keys with dots properly by using `\\.` as a escape sequence.

## v0.3.0 - 2022-08-01

- [Added] Patterns can have groups like in `{a,b}.*`.

## v0.2.2 - 2022-02-01

- [Fixed] Properly handle numeric keys.

## v0.2.1 - 2022-01-13

- [Changed] .gem package now include tests files.

## v0.2.0

- [Added] Allow rejecting patterns like `!*.activerecord`.
- [Changed] New API.

## v0.1.0

- Initial release
