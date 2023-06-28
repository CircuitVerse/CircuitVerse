# VersionGem

## Alternatives

This gem has a very niche purpose, which is:

1. providing introspection of a `Version` module based on a `Version::VERSION` constant string,
2. while not interfering with `gemspec` parsing where the `VERSION` string is traditionally used.

If this isn't **precisely** your use case you may be better off looking at
[`Versionaire`](https://www.alchemists.io/projects/versionaire), a wonderful, performant, well-maintained,
gem from the Alchemists.

For more discussion about this [see issue #2](https://github.com/pboling/version_gem/issues/2)

## Still here?

Give your next library an introspectable `Version` module without breaking your Gemspec.

```ruby
MyLib::Version.to_s # => "1.2.3.rc3"
MyLib::Version.major # => 1
MyLib::Version.minor # => 2
MyLib::Version.patch # => 3
MyLib::Version.pre # => "rc3"
MyLib::Version.to_a # => [1, 2, 3, "rc3"]
MyLib::Version.to_h # => { major: 1, minor: 2, patch: 3, pre: "rc3" }
```

This library was extracted from the gem [`oauth2`](https://github.com/oauth-xx/oauth2).

This gem has no runtime dependencies.

<!--
Numbering rows and badges in each row as a visual "database" lookup,
    as the table is extremely dense, and it can be very difficult to find anything
Putting one on each row here, to document the emoji that should be used, and for ease of copy/paste.

row #s:
1️⃣
2️⃣
3️⃣
4️⃣
5️⃣
6️⃣
7️⃣

badge #s:
⛳️
🖇
🏘
🚎
🖐
🧮
📗

appended indicators:
♻️ - URL needs to be updated from SAAS integration. Find / Replace is insufficient.
-->

|     | Project                        | bundle add version_gem                                                                                                                                                                                                                                                                        |
|:----|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1️⃣ | name, license, docs, standards | [![RubyGems.org][⛳️name-img]][⛳️gem] [![License: MIT][🖇src-license-img]][🖇src-license] [![RubyDoc.info][🚎yard-img]][🚎yard] [![SemVer 2.0.0][🧮semver-img]][semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]               |
| 2️⃣ | version & activity             | [![Gem Version][⛳️version-img]][⛳️gem] [![Total Downloads][🖇DL-total-img]][⛳️gem] [![Download Rank][🏘DL-rank-img]][⛳️gem] [![Source Code][🚎src-home-img]][🚎src-home] [![Open PRs][🖐prs-o-img]][🖐prs-o] [![Closed PRs][🧮prs-c-img]][🧮prs-c] <!--[![Next Version][📗next-img]][📗next]--> |
| 3️⃣ | maintanence & linting          | [![Maintainability][⛳cclim-maint-img♻️]][⛳cclim-maint] [![Helpers][🖇triage-help-img]][🖇triage-help] [![Depfu][🏘depfu-img♻️]][🏘depfu♻️] [![Contributors][🚎contributors-img]][🚎contributors] [![Style][🖐style-wf-img]][🖐style-wf] [![Kloc Roll][🧮kloc-img]][🧮kloc]                      |
| 4️⃣ | testing                        | [![Open Issues][⛳iss-o-img]][⛳iss-o] [![Closed Issues][🖇iss-c-img]][🖇iss-c] [![Supported][🏘sup-wf-img]][🏘sup-wf] [![Heads][🚎heads-wf-img]][🚎heads-wf] [![Unofficial Support][🖐uns-wf-img]][🖐uns-wf] <!--[![MacOS][🧮mac-wf-img]][🧮mac-wf] [![Windows][📗win-wf-img]][📗win-wf]-->      |
| 5️⃣ | coverage & security            | [![CodeClimate][⛳cclim-cov-img♻️]][⛳cclim-cov] [![CodeCov][🖇codecov-img♻️]][🖇codecov] [![Coveralls][🏘coveralls-img]][🏘coveralls] [![Security Policy][🚎sec-pol-img]][🚎sec-pol] [![CodeQL][🖐codeQL-img]][🖐codeQL] [![Code Coverage][🧮cov-wf-img]][🧮cov-wf]                              |
| 6️⃣ | resources                      | [![Discussion][⛳gh-discussions-img]][⛳gh-discussions] [![Get help on Codementor][🖇codementor-img]][🖇codementor] [![Chat][🏘chat-img]][🏘chat] [![Blog][🚎blog-img]][🚎blog] [![Wiki][🖐wiki-img]][🖐wiki]                                                                                     |
| 7️⃣ | spread 💖                      | [![Liberapay Patrons][⛳liberapay-img]][⛳liberapay] [![Sponsor Me][🖇sponsor-img]][🖇sponsor] [![Tweet @ Peter][🏘tweet-img]][🏘tweet] [🌏][aboutme] [👼][angelme] [💻][coderme]                                                                                                                 |

<!--
The link tokens in the following sections should be kept ordered by the row and badge numbering scheme
-->

<!-- 1️⃣ name, license, docs -->
[⛳️gem]: https://rubygems.org/gems/version_gem
[⛳️name-img]: https://img.shields.io/badge/name-version_gem-brightgreen.svg?style=flat
[🖇src-license]: https://opensource.org/licenses/MIT
[🖇src-license-img]: https://img.shields.io/badge/License-MIT-green.svg
[🚎yard]: https://www.rubydoc.info/github/pboling/version_gem
[🚎yard-img]: https://img.shields.io/badge/documentation-rubydoc-brightgreen.svg?style=flat
[🧮semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

<!-- 2️⃣ version & activity -->
[⛳️version-img]: http://img.shields.io/gem/v/version_gem.svg
[🖇DL-total-img]: https://img.shields.io/gem/dt/version_gem.svg
[🏘DL-rank-img]: https://img.shields.io/gem/rt/version_gem.svg
[🚎src-home]: https://github.com/pboling/version_gem
[🚎src-home-img]: https://img.shields.io/badge/source-github-brightgreen.svg?style=flat
[🖐prs-o]: https://github.com/pboling/version_gem/pulls
[🖐prs-o-img]: https://img.shields.io/github/issues-pr/pboling/version_gem
[🧮prs-c]: https://github.com/pboling/version_gem/pulls?q=is%3Apr+is%3Aclosed
[🧮prs-c-img]: https://img.shields.io/github/issues-pr-closed/pboling/version_gem
[📗next]: https://github.com/pboling/version_gem/milestone/1
[📗next-img]: https://img.shields.io/github/milestones/progress/pboling/version_gem/1?label=Next%20Version

<!-- 3️⃣ maintanence & linting -->
[⛳cclim-maint]: https://codeclimate.com/github/pboling/version_gem/maintainability
[⛳cclim-maint-img♻️]: https://api.codeclimate.com/v1/badges/b504d61c4ed1d46aec02/maintainability
[🖇triage-help]: https://www.codetriage.com/pboling/version_gem
[🖇triage-help-img]: https://www.codetriage.com/pboling/version_gem/badges/users.svg
[🏘depfu♻️]: https://depfu.com/github/pboling/version_gem?project_id=35803
[🏘depfu-img♻️]: https://badges.depfu.com/badges/5d8943de6cfdf1ee048ad6d907f3e35b/count.svg
[🚎contributors]: https://github.com/pboling/version_gem/graphs/contributors
[🚎contributors-img]: https://img.shields.io/github/contributors-anon/pboling/version_gem
[🖐style-wf]: https://github.com/pboling/version_gem/actions/workflows/style.yml
[🖐style-wf-img]: https://github.com/pboling/version_gem/actions/workflows/style.yml/badge.svg
[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[🧮kloc-img]: https://img.shields.io/tokei/lines/github.com/pboling/version_gem

<!-- 4️⃣ testing -->
[⛳iss-o]: https://github.com/pboling/version_gem/issues
[⛳iss-o-img]: https://img.shields.io/github/issues-raw/pboling/version_gem
[🖇iss-c]: https://github.com/pboling/version_gem/issues?q=is%3Aissue+is%3Aclosed
[🖇iss-c-img]: https://img.shields.io/github/issues-closed-raw/pboling/version_gem
[🏘sup-wf]: https://github.com/pboling/version_gem/actions/workflows/supported.yml
[🏘sup-wf-img]: https://github.com/pboling/version_gem/actions/workflows/supported.yml/badge.svg
[🚎heads-wf]: https://github.com/pboling/version_gem/actions/workflows/heads.yml
[🚎heads-wf-img]: https://github.com/pboling/version_gem/actions/workflows/heads.yml/badge.svg
[🖐uns-wf]: https://github.com/pboling/version_gem/actions/workflows/unsupported.yml
[🖐uns-wf-img]: https://github.com/pboling/version_gem/actions/workflows/unsupported.yml/badge.svg
[🧮mac-wf]: https://github.com/pboling/version_gem/actions/workflows/macos.yml
[🧮mac-wf-img]: https://github.com/pboling/version_gem/actions/workflows/macos.yml/badge.svg
[📗win-wf]: https://github.com/pboling/version_gem/actions/workflows/windows.yml
[📗win-wf-img]: https://github.com/pboling/version_gem/actions/workflows/windows.yml/badge.svg

<!-- 5️⃣ coverage & security -->
[⛳cclim-cov]: https://codeclimate.com/github/pboling/version_gem/test_coverage
[⛳cclim-cov-img♻️]: https://api.codeclimate.com/v1/badges/b504d61c4ed1d46aec02/test_coverage
[🖇codecov-img♻️]: https://codecov.io/gh/pboling/version_gem/branch/main/graph/badge.svg?token=79c3X4vtfO
[🖇codecov]: https://codecov.io/gh/pboling/version_gem
[🏘coveralls]: https://coveralls.io/github/pboling/version_gem?branch=main
[🏘coveralls-img]: https://coveralls.io/repos/github/pboling/version_gem/badge.svg?branch=main
[🚎sec-pol]: https://github.com/pboling/version_gem/blob/main/SECURITY.md
[🚎sec-pol-img]: https://img.shields.io/badge/security-policy-brightgreen.svg?style=flat
[🖐codeQL]: https://github.com/pboling/version_gem/security/code-scanning
[🖐codeQL-img]: https://github.com/pboling/version_gem/actions/workflows/codeql-analysis.yml/badge.svg
[🧮cov-wf]: https://github.com/pboling/version_gem/actions/workflows/coverage.yml
[🧮cov-wf-img]: https://github.com/pboling/version_gem/actions/workflows/coverage.yml/badge.svg

<!-- 6️⃣ resources -->
[⛳gh-discussions]: https://github.com/pboling/version_gem/discussions
[⛳gh-discussions-img]: https://img.shields.io/github/discussions/pboling/version_gem
[🖇codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
[🖇codementor-img]: https://cdn.codementor.io/badges/get_help_github.svg
[🏘chat]: https://gitter.im/pboling/version_gem
[🏘chat-img]: https://img.shields.io/gitter/room/pboling/version_gem.svg
[🚎blog]: http://www.railsbling.com/tags/version_gem/
[🚎blog-img]: https://img.shields.io/badge/blog-railsbling-brightgreen.svg?style=flat
[🖐wiki]: https://github.com/pboling/version_gem/wiki
[🖐wiki-img]: https://img.shields.io/badge/wiki-examples-brightgreen.svg?style=flat

<!-- 7️⃣ spread 💖 -->
[⛳liberapay-img]: https://img.shields.io/liberapay/patrons/pboling.svg?logo=liberapay
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇sponsor-img]: https://img.shields.io/badge/sponsor-pboling.svg?style=social&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🏘tweet-img]: https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow
[🏘tweet]: http://twitter.com/galtzo

<!-- Maintainer Contact Links -->
[railsbling]: http://www.railsbling.com
[peterboling]: http://www.peterboling.com
[aboutme]: https://about.me/peter.boling
[angelme]: https://angel.co/peter-boling
[coderme]:http://coderwall.com/pboling

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add version_gem

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install version_gem

## Usage

In the standard `bundle gem my_lib` code you get the following in `lib/my_lib/version.rb`:

```ruby
module MyLib
  VERSION = "0.1.0"
end
```

Change it to a nested `Version` namespace (the one implied by the path => namespace convention):

```ruby
module MyLib
  module Version
    VERSION = "0.1.0"
  end
end
```

Now add the following near the top of the file the manages requiring external libraries.
Using the same example of `bundle gem my_lib`, this would be `lib/my_lib.rb`.

```ruby
require "version_gem"
```

Then, add the following wherever you want in the same file (recommend the bottom).

```ruby
MyLib::Version.class_eval do
  extend VersionGem::Basic
end
```

And now you have some version introspection methods available:

```ruby
MyLib::Version.to_s # => "0.1.0"
MyLib::Version.major # => 0
MyLib::Version.minor # => 1
MyLib::Version.patch # => 0
MyLib::Version.pre # => ""
MyLib::Version.to_a # => [0, 1, 0]
MyLib::Version.to_h # => { major: 0, minor: 1, patch: 0, pre: "" }
```

### Side benefit

Your `version.rb` file now abides the Ruby convention of directory / path matching the namespace / class!

### Caveat

This design keeps your `version.rb` file compatible with the way `gemspec` files use them.
This means that the introspection is _not_ available within the gemspec.
The enhancement from this gem is only available at runtime.

### RSpec Matchers

In `spec_helper.rb`:
```ruby
require 'version_gem/rspec'
```

Then you can write a test like:

```ruby
RSpec.describe MyLib::Version do
  it_behaves_like 'a Version module', described_class
end

# Or, if you want to write your own, here is the a la carte menu:
RSpec.describe MyLib::Version do
  it "is a Version module" do
    expect(described_class).is_a?(Module)
    expect(described_class).to have_version_constant
    expect(described_class).to have_version_as_string
    expect(described_class.to_s).to be_a(String)
    expect(described_class).to have_major_as_integer
    expect(described_class).to have_minor_as_integer
    expect(described_class).to have_patch_as_integer
    expect(described_class).to have_pre_as_nil_or_string
    expect(described_class.to_h.keys).to match_array(%i[major minor patch pre])
    expect(described_class.to_a).to be_a(Array)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

See [CONTRIBUTING.md][contributing]

## Contributors

[![Contributors](https://contrib.rocks/image?repo=pboling/version_gem)]("https://github.com/pboling/version_gem/graphs/contributors")

Made with [contributors-img](https://contrib.rocks).

## License

The gem is available as open source under the terms of
the [MIT License][license] [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)][license-ref].
See [LICENSE][license] for the official [Copyright Notice][copyright-notice-explainer].

* Copyright (c) 2022 [Peter H. Boling][peterboling] of [Rails Bling][railsbling]

## Code of Conduct

Everyone interacting in the VersionGem project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pboling/version_gem/blob/main/CODE_OF_CONDUCT.md).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations of this scheme should be reported as
bugs. Specifically, if a minor or patch version is released that breaks backward compatibility, a new version should be
immediately released that restores compatibility. Breaking changes to the public API will only be introduced with new
major versions.

As a result of this policy, you can (and should) specify a dependency on this gem using
the [Pessimistic Version Constraint][pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency "version_gem", "~> 1.1"
```

## Security

See [SECURITY.md](https://github.com/pboling/version_gem/blob/main/SECURITY.md).

[copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year

[gh_discussions]: https://github.com/pboling/version_gem/discussions

[conduct]: https://github.com/pboling/version_gem/blob/main/CODE_OF_CONDUCT.md

[contributing]: https://github.com/pboling/version_gem/blob/main/CONTRIBUTING.md

[security]: https://github.com/pboling/version_gem/blob/main/SECURITY.md

[license]: https://github.com/pboling/version_gem/blob/main/LICENSE.txt

[license-ref]: https://opensource.org/licenses/MIT

[semver]: http://semver.org/

[pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint

[aboutme]: https://about.me/peter.boling

[angelme]: https://angel.co/peter-boling

[coderme]:http://coderwall.com/pboling

[followme-img]: https://img.shields.io/twitter/follow/galtzo.svg?style=social&label=Follow

[tweetme]: http://twitter.com/galtzo

[politicme]: https://nationalprogressiveparty.org

[documentation]: https://rubydoc.info/github/pboling/version_gem/main

[source]: https://github.com/pboling/version_gem/

[actions]: https://github.com/pboling/version_gem/actions

[issues]: https://github.com/pboling/version_gem/issues

[climate_maintainability]: https://codeclimate.com/github/pboling/version_gem/maintainability

[climate_coverage]: https://codeclimate.com/github/pboling/version_gem/test_coverage

[codecov_coverage]: https://codecov.io/gh/pboling/version_gem

[code_triage]: https://www.codetriage.com/pboling/version_gem

[blogpage]: http://www.railsbling.com/tags/version_gem/

[rubygems]: https://rubygems.org/gems/version_gem

[chat]: https://gitter.im/pboling/version_gem?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

[maintenancee_policy]: https://guides.rubyonrails.org/maintenance_policy.html#security-issues

[liberapay_donate]: https://liberapay.com/pboling/donate

[gh_sponsors]: https://github.com/sponsors/pboling
