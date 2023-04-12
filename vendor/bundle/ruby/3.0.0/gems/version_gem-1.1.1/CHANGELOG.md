# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Fixed
### Removed

## [1.1.1] - 2022-09-19 ([tag][1.1.1t])
### Added
- Alternatives section to README.md (@pboling)
- Signing cert for gem releases (@pboling)
- Mailing List and other metadata URIs (@pboling)
- Checksums for released gems (@pboling)
### Changed
- SECURITY.md policy (@pboling)
- Version methods are now memoized (||=) on initial call for performance (@pboling)
- Gem releases are now cryptographically signed (@pboling)

## [1.1.0] - 2022-06-24 ([tag][1.1.0t])
### Fixed
- to_a uses same type casting as major, minor, patch, and pre (@pboling)
### Added
- RSpec Matchers and Shared Example (@pboling)

## [1.0.2] - 2022-06-23 ([tag][1.0.2t])
### Added
- Delay loading of library code until after code coverage tool is loaded (@pboling)

## [1.0.1] - 2022-06-23 ([tag][1.0.1t])
### Added
- CI Build improvements (@pboling)
- Code coverage reporting (@pboling)
- Documentation improvements (@pboling)
- Badges! (@pboling)

## [1.0.0] - 2022-06-21 ([tag][1.0.0t])
### Added
- Initial release, with basic version parsing API (@pboling)

[Unreleased]: https://gitlab.com/oauth-xx/version_gem/-/compare/v1.1.1...HEAD
[1.1.1]: https://gitlab.com/oauth-xx/version_gem/-/compare/v1.1.0...v1.1.1
[1.1.1t]: https://gitlab.com/oauth-xx/oauth2/-/tags/v1.1.1
[1.1.0]: https://gitlab.com/oauth-xx/version_gem/-/compare/v1.0.2...v1.1.0
[1.1.0t]: https://gitlab.com/oauth-xx/oauth2/-/tags/v1.1.0
[1.0.2]: https://gitlab.com/oauth-xx/version_gem/-/compare/v1.0.1...v1.0.2
[1.0.2t]: https://gitlab.com/oauth-xx/oauth2/-/tags/v1.0.2
[1.0.1]: https://gitlab.com/oauth-xx/version_gem/-/compare/v1.0.0...v1.0.1
[1.0.1t]: https://gitlab.com/oauth-xx/oauth2/-/tags/v1.0.1
[1.0.0]: https://gitlab.com/oauth-xx/version_gem/-/compare/a3055964517c159bf214712940982034b75264be...v1.0.0
[1.0.0t]: https://gitlab.com/oauth-xx/oauth2/-/tags/v1.0.0
