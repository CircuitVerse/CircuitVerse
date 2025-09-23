# 🔖 VersionGem

[![Version][👽versioni]][👽version]
[![License: MIT][📄license-img]][📄license-ref]
[![Downloads Rank][👽dl-ranki]][👽dl-rank]
[![Open Source Helpers][👽oss-helpi]][👽oss-help]
[![Depfu][🔑depfui♻️]][🔑depfu]
[![CodeCov Test Coverage][🔑codecovi♻️]][🔑codecov]
[![Coveralls Test Coverage][🔑coveralls-img]][🔑coveralls]
[![CodeClimate Test Coverage][🔑cc-covi♻️]][🔑cc-cov]
[![Maintainability][🔑cc-mnti♻️]][🔑cc-mnt]
[![CI Heads][🚎3-hd-wfi]][🚎3-hd-wf]
[![CI Current][🚎11-c-wfi]][🚎11-c-wf]
[![CI Truffle Ruby][🚎9-t-wfi]][🚎9-t-wf]
[![CI JRuby][🚎10-j-wfi]][🚎10-j-wf]
[![CI Supported][🚎6-s-wfi]][🚎6-s-wf]
[![CI Legacy][🚎4-lg-wfi]][🚎4-lg-wf]
[![CI Unsupported][🚎7-us-wfi]][🚎7-us-wf]
[![CI Ancient][🚎1-an-wfi]][🚎1-an-wf]
[![CI Test Coverage][🚎2-cov-wfi]][🚎2-cov-wf]
[![CI Style][🚎5-st-wfi]][🚎5-st-wf]

---

[![Liberapay Patrons][⛳liberapay-img]][⛳liberapay]
[![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor]
[![Buy me a coffee][🖇buyme-small-img]][🖇buyme]
[![Donate on Polar][🖇polar-img]][🖇polar]
[![Donate to my FLOSS or refugee efforts at ko-fi.com][🖇kofi-img]][🖇kofi]
[![Donate to my FLOSS or refugee efforts using Patreon][🖇patreon-img]][🖇patreon]

## 🧐 Alternatives

This gem has a very niche purpose, which is:

1. providing introspection of a `Version` module based on a `VERSION` constant string within it,
2. while not interfering with `gemspec` parsing where the `VERSION` string is traditionally used,
3. allowing 100% test coverage of Ruby code, including the `Version` module.

As proof in the pudding, this gem achieves 100% test coverage for lines and branches,
all 117 and 4 of them, respectively; coverage enabled in part by patterns from this library.
You can make it happen for your library too!

If this isn't **precisely** your use case you may be better off looking at
_[versionaire](https://www.alchemists.io/projects/versionaire)_, a wonderful, performant, well-maintained,
gem from the Alchemists, or _[version_sorter](https://rubygems.org/gems/version_sorter)_ from GitHub.

For more discussion about this [see issue #2](https://gitlab.com/oauth-xx/version_gem/-/issues/2)

## 🚀 Still here?

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

This library was extracted from the gem _[oauth2](https://gitlab.com/oauth-xx/oauth2)_.

This gem has no runtime dependencies.

## 💡 Info you can shake a stick at

| Tokens to Remember      | [![Gem name][⛳️name-img]][⛳️gem-name] [![Gem namespace][⛳️namespace-img]][⛳️gem-namespace]                                                                                                                                                                                                                                                                                                                                                                          |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Works with JRuby        | [![JRuby 9.1 Compat][💎jruby-9.1i]][🚎10-j-wf] [![JRuby 9.2 Compat][💎jruby-9.2i]][🚎10-j-wf] [![JRuby 9.3 Compat][💎jruby-9.3i]][🚎10-j-wf] [![JRuby 9.4 Compat][💎jruby-9.4i]][🚎10-j-wf] [![JRuby 10.0 Compat][💎jruby-c-i]][🚎11-c-wf] [![JRuby HEAD Compat][💎jruby-headi]][🚎3-hd-wf]                                                                                                                                                                         |
| Works with Truffle Ruby | [![Truffle Ruby 22.3 Compat][💎truby-22.3i]][🚎9-t-wf] [![Truffle Ruby 23.0 Compat][💎truby-23.0i]][🚎9-t-wf] [![Truffle Ruby 23.1 Compat][💎truby-23.1i]][🚎9-t-wf] [![Truffle Ruby 24.1 Compat][💎truby-c-i]][🚎11-c-wf] [![Truffle Ruby HEAD Compat][💎truby-headi]][🚎3-hd-wf]                                                                                                                                                                                  |
| Works with MRI Ruby 3   | [![Ruby 3.0 Compat][💎ruby-3.0i]][🚎4-lg-wf] [![Ruby 3.1 Compat][💎ruby-3.1i]][🚎6-s-wf] [![Ruby 3.2 Compat][💎ruby-3.2i]][🚎6-s-wf] [![Ruby 3.3 Compat][💎ruby-3.3i]][🚎6-s-wf] [![Ruby 3.4 Compat][💎ruby-c-i]][🚎11-c-wf] [![Ruby HEAD Compat][💎ruby-headi]][🚎3-hd-wf]                                                                                                                                                                                         |
| Works with MRI Ruby 2   | [![Ruby 2.3 Compat][💎ruby-2.3i]][🚎1-an-wf] [![Ruby 2.4 Compat][💎ruby-2.4i]][🚎1-an-wf] [![Ruby 2.5 Compat][💎ruby-2.5i]][🚎1-an-wf] [![Ruby 2.6 Compat][💎ruby-2.6i]][🚎7-us-wf] [![Ruby 2.7 Compat][💎ruby-2.7i]][🚎7-us-wf]                                                                                                                                                                                                                                    |
| Source                  | [![Source on GitLab.com][📜src-gl-img]][📜src-gl] [![Source on Github.com][📜src-gh-img]][📜src-gh] [![The best SHA: dQw4w9WgXcQ!][🧮kloc-img]][🧮kloc]                                                                                                                                                                                                                                                                                                             |
| Documentation           | [![Current release on RubyDoc.info][📜docs-cr-rd-img]][🚎yard-current] [![HEAD on RubyDoc.info][📜docs-head-rd-img]][🚎yard-head] [![BDFL Blog][🚂bdfl-blog-img]][🚂bdfl-blog] [![Wiki][📜wiki-img]][📜wiki]                                                                                                                                                                                                                                                        |
| Compliance              | [![License: MIT][📄license-img]][📄license-ref] [![📄ilo-declaration-img]][📄ilo-declaration] [![Security Policy][🔐security-img]][🔐security] [![CodeQL][🖐codeQL-img]][🖐codeQL] [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct] [![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog] [![Gitmoji Commits][📌gitmoji-img]][📌gitmoji]                                                             |
| Expert 1:1 Support      | [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork] `or` [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]                                                                                                                                                                                                                                                                                    |
| Enterprise Support      | [![Get help from me on Tidelift][🏙️entsup-tidelift-img]][🏙️entsup-tidelift]<br/>💡Subscribe for support guarantees covering _all_ FLOSS dependencies!<br/>💡Tidelift is part of [Sonar][🏙️entsup-tidelift-sonar]!<br/>💡Tidelift pays maintainers to maintain the software you depend on!<br/>📊`@`Pointy Haired Boss: An [enterprise support][🏙️entsup-tidelift] subscription is "[never gonna let you down][🧮kloc]", and *supports* open source maintainers! |
| Comrade BDFL 🎖️        | [![Follow Me on LinkedIn][💖🖇linkedin-img]][💖🖇linkedin] [![Follow Me on Ruby.Social][💖🐘ruby-mast-img]][💖🐘ruby-mast] [![Follow Me on Bluesky][💖🦋bluesky-img]][💖🦋bluesky] [![Contact BDFL][🚂bdfl-contact-img]][🚂bdfl-contact] [![My technical writing][💖💁🏼‍♂️devto-img]][💖💁🏼‍♂️devto]                                                                                                                                                              |
| `...` 💖                | [![Find Me on WellFound:][💖✌️wellfound-img]][💖✌️wellfound] [![Find Me on CrunchBase][💖💲crunchbase-img]][💖💲crunchbase] [![My LinkTree][💖🌳linktree-img]][💖🌳linktree] [![More About Me][💖💁🏼‍♂️aboutme-img]][💖💁🏼‍♂️aboutme] [🧊][💖🧊berg] [🐙][💖🐙hub]  [🛖][💖🛖hut] [🧪][💖🧪lab]                                                                                                                                                                   |

## ✨ Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add version_gem

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install version_gem

### 🔒 Secure Installation

`version_gem` is cryptographically signed, and with verifiable [SHA-256 and SHA-512][💎SHA_checksums] checksums by
[stone_checksums][💎stone_checksums]. Be sure the gem you install hasn’t been tampered with
by following the instructions below.

Add my public key (if you haven’t already, expires 2045-04-29) as a trusted certificate:

```shell
gem cert --add <(curl -Ls https://raw.github.com/oauth-xx/version_gem/main/certs/pboling.pem)
```

You only need to do that once.  Then proceed to install with:

```shell
gem install version_gem -P HighSecurity
```

The `HighSecurity` trust profile will verify signed gems, and not allow the installation of unsigned dependencies.

If you want to up your security game full-time:

```shell
bundle config set --global trust-policy MediumSecurity
```

`MediumSecurity` instead of `HighSecurity` is necessary if not all the gems you use are signed.

NOTE: Be prepared to track down certs for signed gems and add them the same way you added mine.

## 🔧 Basic Usage

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

### Side benefit #1

You can reference the version from your gemspec, keeping the version string DRY,
*and* still get accurate code coverage!

```ruby
# Get the GEMFILE_VERSION without *require* "my_gem/version", for code coverage accuracy
# See: https://github.com/simplecov-ruby/simplecov/issues/557#issuecomment-2630782358
# Kernel.load because load is overloaded in RubyGems during gemspec evaluation
Kernel.load("lib/my_gem/version.rb")
gem_version = MyGem::Version::VERSION
MyGem::Version.send(:remove_const, :VERSION)

Gem::Specification.new do |spec|
  # ...
  spec.version = gem_version
end
```

### Side benefit #2

Your `version.rb` file now abides the Ruby convention of directory / path matching the namespace / class!

## Epoch Usage (Epoch Semantic Versioning, as of version 1.1.7)

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

The Epoch and Major versions are derived from the formula:

```
{EPOCH * 1000 + MAJOR}.MINOR.PATCH
```

This will start your library with the following version segments:

* `epoch = 0`
* `major = 0`
* `minor = 1`
* `patch = 0`
* `pre = nil`

And the segments are defined as:

```
EPOCH: Increment when you make significant or groundbreaking changes.
MAJOR: Increment when you make minor incompatible API changes.
MINOR: Increment when you add functionality in a backwards-compatible manner.
PATCH: Increment when you make backwards-compatible bug fixes.
```

Therefore, if you set your version number to:

```ruby
VERSION = "27016.42.86-pre.7"
```

You will get the following version segments:

```
{
  epoch: 27,
  major: 16,
  minor: 42,
  patch: 86,
  pre: "pre-7",
}
```

Now add the following near the top of the file the manages requiring external libraries.
Using the same example of `bundle gem my_lib`, this would be `lib/my_lib.rb`.

```ruby
require "version_gem"
```

Then, add the following wherever you want in the same file (recommend the bottom).

```ruby
MyLib::Version.class_eval do
  extend VersionGem::Epoch
end
```

And now you have some version introspection methods available:

```ruby
MyLib::Version.to_s # => "1024.3.8"
MyLib::Version.epoch # => 1
MyLib::Version.major # => 24
MyLib::Version.minor # => 3
MyLib::Version.patch # => 8
MyLib::Version.pre # => ""
MyLib::Version.to_a # => [1, 24, 3, 8]
MyLib::Version.to_h # => { epoch: 1, major: 24, minor: 3, patch: 8, pre: "" }
```

### Usage with Zeitwerk

The pattern of `version.rb` breaking the ruby convention of directory / path matching the namespace / class
is so entrenched that the `zeitwerk` library has a special carve-out for it. 🥺
RubyGems using this "bad is actually good" pattern are encouraged to use `Zeitwerk.for_gem`.

**Do not do that ^** if you use this gem.

#### Simple Zeitwerk Example

Create a gem like this (keeping with the `MyLib` theme):

```shell
bundle gem my_lib
```

Then following the usage instructions above, you edit your primary namespace file @ `lib/my_lib.rb`,
but inject the Zeitwerk loader.

```ruby
# frozen_string_literal: true

require_relative "my_lib/version"

module MyLib
  class Error < StandardError; end
  # Your code goes here...
end

loader = Zeitwerk::Loader.new
loader.tag = File.basename(__FILE__, ".rb")
loader.push_dir("lib/my_lib", namespace: MyLib)
loader.setup # ready!
loader.eager_load(force: true) # optional!

MyLib::Version.class_eval do
  extend VersionGem::Basic
end
```

#### Complex Zeitwerk Example

Maybe you would like to contribute one?

#### Query Ruby Version (as of version 1.1.2)

In Continuous Integration environments for libraries that run against many versions of Ruby,
I often need to configure things discretely per Ruby version, and doing so forced me to repeat
a significant amount of boilerplate code across each project.

Thus `VersionGem::Ruby` was born.  It has the two optimized methods I always need:

```ruby
engine = "ruby"
version = "2.7.7"
gte_minimum_version?(version, engine)  # Is the current version of Ruby greater than or equal to some minimum?

major = 3
minor = 2
actual_minor_version?(major, minor, engine) # Is the current version of Ruby precisely a specific minor version of Ruby?
```

`Version::Ruby` is *not loaded* by default.  If you want to use it, you must require it as:
```ruby
require "version_gem/ruby"
```

Normally I do this in my `spec/spec_helper.rb`, and/or `.simplecov` files.
Occasionally in my `Rakefile`.

### Caveat

This design keeps your `version.rb` file compatible with the way `gemspec` files use them.
This means that the introspection is _not_ available within the gemspec.
The enhancement from this gem is only available at runtime.

### RSpec Matchers

In `spec_helper.rb`:
```ruby
require "version_gem/rspec"
```

Then you can write a test like:

```ruby
RSpec.describe(MyLib::Version) do
  it_behaves_like "a Version module", described_class
end

# Or, if you want to write your own, here is the á la carte menu:
RSpec.describe(MyLib::Version) do
  it "is a Version module" do
    expect(described_class).is_a?(Module)
    expect(described_class).to(have_version_constant)
    expect(described_class).to(have_version_as_string)
    expect(described_class.to_s).to(be_a(String))
    expect(described_class).to(have_major_as_integer)
    expect(described_class).to(have_epoch_as_integer)
    expect(described_class).to(have_minor_as_integer)
    expect(described_class).to(have_patch_as_integer)
    expect(described_class).to(have_pre_as_nil_or_string)
    # This would be %i[epoch major minor patch pre] for epoch version schemes
    expect(described_class.to_h.keys).to(match_array(%i[major minor patch pre]))
    expect(described_class.to_a).to(be_a(Array))
  end
end
```

## 🔐 Security

See [SECURITY.md][🔐security].

## 🤝 Contributing

If you need some ideas of where to help, you could work on adding more code coverage,
or if it is already 💯 (see [below](#code-coverage)) then check [issues][🤝issues], or [PRs][🤝pulls],
or use the gem and think about how it could be better.

We [![Keep A Changelog][📗keep-changelog-img]][📗keep-changelog] so if you make changes, remember to update it.

See [CONTRIBUTING.md][🤝contributing] for more detailed instructions.

### Code Coverage

[![Coverage Graph][🔑codecov-g♻️]][🔑codecov]

### 🪇 Code of Conduct

Everyone interacting in this project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct].

## 🌈 Contributors

[![Contributors][🖐contributors-img]][🖐contributors]

Made with [contributors-img][🖐contrib-rocks].

Also see GitLab Contributors: [https://gitlab.com/oauth-xx/version_gem/-/graphs/main][🚎contributors-gl]

## ⭐️ Star History

<a href="https://star-history.com/#oauth-xx/version_gem&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oauth-xx/version_gem&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=oauth-xx/version_gem&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=oauth-xx/version_gem&type=Date" />
 </picture>
</a>

## 📌 Versioning

This Library adheres to [![Epoch Semantic Versioning][📌semver-img]][📌semver].
Violations of this scheme should be reported as bugs.
Specifically, if a minor or patch version is released that breaks backward compatibility,
a new version should be immediately released that restores compatibility.
Breaking changes to the public API, including dropping a supported platform (i.e. minor version of Ruby),
will only be introduced with new major versions.
Epoch will only be bumped if there are dramatic changes, and that is not expected to happen ever.

### 📌 Is "Platform Support" part of the public API?

Yes.  But I'm obligated to include notes...

SemVer should, but doesn't explicitly, say that dropping support for specific Platforms
is a *breaking change* to an API.
It is obvious to many, but not all, and since the spec is silent, the bike shedding is endless.

> dropping support for a platform is both obviously and objectively a breaking change

- Jordan Harband (@ljharb, maintainer of SemVer) [in SemVer issue 716][📌semver-breaking]

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]

As a result of this policy, and the interpretive lens used by the maintainer,
you can (and should) specify a dependency on these libraries using
the [Pessimistic Version Constraint][📌pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("version_gem", "~> 1.1")
```

See [CHANGELOG.md][📌changelog] for list of releases.

## 📄 License

The gem is available as open source under the terms of
the [MIT License][📄license] [![License: MIT][📄license-img]][📄license-ref].
See [LICENSE.txt][📄license] for the official [Copyright Notice][📄copyright-notice-explainer].

### © Copyright

<p>
  Copyright (c) 2022 - 2025 Peter H. Boling,
  <a href="https://railsbling.com">
    RailsBling.com
    <picture>
      <img alt="Rails Bling" height="20" src="https://railsbling.com/images/logos/RailsBling-TrainLogo.svg" />
    </picture>
  </a>
</p>

## 🤑 One more thing

You made it to the bottom of the page,
so perhaps you'll indulge me for another 20 seconds.
I maintain many dozens of gems, including this one,
because I want Ruby to be a great place for people to solve problems, big and small.
Please consider supporting my efforts via the giant yellow link below,
or one of the others at the head of this README.

[![Buy me a latte][🖇buyme-img]][🖇buyme]

[✇bundle-group-pattern]: https://gist.github.com/pboling/4564780
[🏘chat]: https://gitter.im/oauth-xx/version_gem
[🏘chat-img]: https://img.shields.io/gitter/room/oauth-xx/version_gem.svg
[⛳️gem-namespace]: https://github.com/oauth-xx/version_gem/blob/main/lib/version_gem.rb
[⛳️namespace-img]: https://img.shields.io/badge/namespace-VersionGem-brightgreen.svg?style=flat&logo=ruby&logoColor=white
[⛳️gem-name]: https://rubygems.org/gems/version_gem
[⛳️name-img]: https://img.shields.io/badge/name-version__gem-brightgreen.svg?style=flat&logo=rubygems&logoColor=red
[🚂bdfl-blog]: http://www.railsbling.com/tags/version_gem
[🚂bdfl-blog-img]: https://img.shields.io/badge/blog-railsbling-0093D0.svg?style=for-the-badge&logo=rubyonrails&logoColor=orange
[🚂bdfl-contact]: http://www.railsbling.com/contact
[🚂bdfl-contact-img]: https://img.shields.io/badge/Contact-BDFL-0093D0.svg?style=flat&logo=rubyonrails&logoColor=red
[💖🖇linkedin]: http://www.linkedin.com/in/peterboling
[💖🖇linkedin-img]: https://img.shields.io/badge/PeterBoling-LinkedIn-0B66C2?style=flat&logo=newjapanprowrestling
[💖✌️wellfound]: https://angel.co/u/peter-boling
[💖✌️wellfound-img]: https://img.shields.io/badge/peter--boling-orange?style=flat&logo=wellfound
[💖💲crunchbase]: https://www.crunchbase.com/person/peter-boling
[💖💲crunchbase-img]: https://img.shields.io/badge/peter--boling-purple?style=flat&logo=crunchbase
[💖🐘ruby-mast]: https://ruby.social/@galtzo
[💖🐘ruby-mast-img]: https://img.shields.io/mastodon/follow/109447111526622197?domain=https%3A%2F%2Fruby.social&style=flat&logo=mastodon&label=Ruby%20%40galtzo
[💖🦋bluesky]: https://bsky.app/profile/galtzo.com
[💖🦋bluesky-img]: https://img.shields.io/badge/@galtzo.com-0285FF?style=flat&logo=bluesky&logoColor=white
[💖🌳linktree]: https://linktr.ee/galtzo
[💖🌳linktree-img]: https://img.shields.io/badge/galtzo-purple?style=flat&logo=linktree
[💖💁🏼‍♂️devto]: https://dev.to/galtzo
[💖💁🏼‍♂️devto-img]: https://img.shields.io/badge/dev.to-0A0A0A?style=flat&logo=devdotto&logoColor=white
[💖💁🏼‍♂️aboutme]: https://about.me/peter.boling
[💖💁🏼‍♂️aboutme-img]: https://img.shields.io/badge/about.me-0A0A0A?style=flat&logo=aboutme&logoColor=white
[💖🧊berg]: https://codeberg.org/pboling
[💖🐙hub]: https://github.org/pboling
[💖🛖hut]: https://sr.ht/~galtzo/
[💖🧪lab]: https://gitlab.com/pboling
[👨🏼‍🏫expsup-upwork]: https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share
[👨🏼‍🏫expsup-upwork-img]: https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white
[👨🏼‍🏫expsup-codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
[👨🏼‍🏫expsup-codementor-img]: https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white
[🏙️entsup-tidelift]: https://tidelift.com/subscription
[🏙️entsup-tidelift-img]: https://img.shields.io/badge/Tidelift_and_Sonar-Enterprise_Support-FD3456?style=for-the-badge&logo=sonar&logoColor=white
[🏙️entsup-tidelift-sonar]: https://blog.tidelift.com/tidelift-joins-sonar
[💁🏼‍♂️peterboling]: http://www.peterboling.com
[🚂railsbling]: http://www.railsbling.com
[📜src-gl-img]: https://img.shields.io/badge/GitLab-FBA326?style=for-the-badge&logo=Gitlab&logoColor=orange
[📜src-gl]: https://gitlab.com/oauth-xx/version_gem/
[📜src-gh-img]: https://img.shields.io/badge/GitHub-238636?style=for-the-badge&logo=Github&logoColor=green
[📜src-gh]: https://github.com/oauth-xx/version_gem
[📜docs-cr-rd-img]: https://img.shields.io/badge/RubyDoc-Current_Release-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜docs-head-rd-img]: https://img.shields.io/badge/RubyDoc-HEAD-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜wiki]: https://gitlab.com/oauth-xx/version_gem/-/wikis/home
[📜wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=Wiki&logoColor=white
[👽dl-rank]: https://rubygems.org/gems/version_gem
[👽dl-ranki]: https://img.shields.io/gem/rd/version_gem.svg
[👽oss-help]: https://www.codetriage.com/oauth-xx/version_gem
[👽oss-helpi]: https://www.codetriage.com/oauth-xx/version_gem/badges/users.svg
[👽version]: https://rubygems.org/gems/version_gem
[👽versioni]: https://img.shields.io/gem/v/version_gem.svg
[🔑cc-mnt]: https://qlty.sh/gh/oauth-xx/projects/version_gem
[🔑cc-mnti♻️]: https://qlty.sh/badges/19404e90-9168-451a-8dac-882382cb768d/maintainability.svg
[🔑cc-cov]: https://qlty.sh/gh/oauth-xx/projects/version_gem
[🔑cc-covi♻️]: https://qlty.sh/badges/19404e90-9168-451a-8dac-882382cb768d/test_coverage.svg
[🔑codecov]: https://codecov.io/gh/oauth-xx/version_gem
[🔑codecovi♻️]: https://codecov.io/gh/oauth-xx/version_gem/branch/main/graph/badge.svg?token=cc6UdZCpAL
[🔑coveralls]: https://coveralls.io/github/oauth-xx/version_gem?branch=main
[🔑coveralls-img]: https://coveralls.io/repos/github/oauth-xx/version_gem/badge.svg?branch=main
[🔑depfu]: https://depfu.com/github/oauth-xx/version_gem
[🔑depfui♻️]: https://badges.depfu.com/badges/6c9b45362951b872127f9e46d39bed76/count.svg
[🖐codeQL]: https://github.com/oauth-xx/version_gem/security/code-scanning
[🖐codeQL-img]: https://github.com/oauth-xx/version_gem/actions/workflows/codeql-analysis.yml/badge.svg
[🚎1-an-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/ancient.yml
[🚎1-an-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/ancient.yml/badge.svg
[🚎2-cov-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/coverage.yml
[🚎2-cov-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/coverage.yml/badge.svg
[🚎3-hd-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/heads.yml
[🚎3-hd-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/heads.yml/badge.svg
[🚎4-lg-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/legacy.yml
[🚎4-lg-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/legacy.yml/badge.svg
[🚎5-st-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/style.yml
[🚎5-st-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/style.yml/badge.svg
[🚎6-s-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/supported.yml
[🚎6-s-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/supported.yml/badge.svg
[🚎7-us-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/unsupported.yml
[🚎7-us-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/unsupported.yml/badge.svg
[🚎9-t-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/truffle.yml
[🚎9-t-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/truffle.yml/badge.svg
[🚎10-j-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/jruby.yml
[🚎10-j-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/jruby.yml/badge.svg
[🚎11-c-wf]: https://github.com/oauth-xx/version_gem/actions/workflows/current.yml
[🚎11-c-wfi]: https://github.com/oauth-xx/version_gem/actions/workflows/current.yml/badge.svg
[⛳liberapay-img]: https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🖇polar-img]: https://img.shields.io/badge/polar-donate-yellow.svg
[🖇polar]: https://polar.sh/pboling
[🖇kofi-img]: https://img.shields.io/badge/a_more_different_coffee-✓-yellow.svg
[🖇kofi]: https://ko-fi.com/O5O86SNP4
[🖇patreon-img]: https://img.shields.io/badge/patreon-donate-yellow.svg
[🖇patreon]: https://patreon.com/galtzo
[🖇buyme-img]: https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20latte&emoji=&slug=pboling&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff
[🖇buyme]: https://www.buymeacoffee.com/pboling
[🖇buyme-small-img]: https://img.shields.io/badge/buy_me_a_coffee-✓-yellow.svg?style=flat
[💎ruby-2.3i]: https://img.shields.io/badge/Ruby-2.3-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.4i]: https://img.shields.io/badge/Ruby-2.4-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.5i]: https://img.shields.io/badge/Ruby-2.5-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.6i]: https://img.shields.io/badge/Ruby-2.6-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-2.7i]: https://img.shields.io/badge/Ruby-2.7-DF00CA?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.0i]: https://img.shields.io/badge/Ruby-3.0-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.1i]: https://img.shields.io/badge/Ruby-3.1-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.2i]: https://img.shields.io/badge/Ruby-3.2-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.3i]: https://img.shields.io/badge/Ruby-3.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-c-i]: https://img.shields.io/badge/Ruby-current-CC342D?style=for-the-badge&logo=ruby&logoColor=green
[💎ruby-headi]: https://img.shields.io/badge/Ruby-HEAD-CC342D?style=for-the-badge&logo=ruby&logoColor=blue
[💎truby-22.3i]: https://img.shields.io/badge/Truffle_Ruby-22.3-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-23.0i]: https://img.shields.io/badge/Truffle_Ruby-23.0-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-23.1i]: https://img.shields.io/badge/Truffle_Ruby-23.1-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-c-i]: https://img.shields.io/badge/Truffle_Ruby-current-34BCB1?style=for-the-badge&logo=ruby&logoColor=green
[💎truby-headi]: https://img.shields.io/badge/Truffle_Ruby-HEAD-34BCB1?style=for-the-badge&logo=ruby&logoColor=blue
[💎jruby-9.1i]: https://img.shields.io/badge/JRuby-9.1-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-9.2i]: https://img.shields.io/badge/JRuby-9.2-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-9.3i]: https://img.shields.io/badge/JRuby-9.3-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-9.4i]: https://img.shields.io/badge/JRuby-9.4-FBE742?style=for-the-badge&logo=ruby&logoColor=red
[💎jruby-c-i]: https://img.shields.io/badge/JRuby-current-FBE742?style=for-the-badge&logo=ruby&logoColor=green
[💎jruby-headi]: https://img.shields.io/badge/JRuby-HEAD-FBE742?style=for-the-badge&logo=ruby&logoColor=blue
[🤝issues]: https://github.com/oauth-xx/version_gem/issues
[🤝pulls]: https://github.com/oauth-xx/version_gem/pulls
[🤝contributing]: CONTRIBUTING.md
[🔑codecov-g♻️]: https://codecov.io/gh/oauth-xx/version_gem/graphs/tree.svg?token=cc6UdZCpAL
[🖐contrib-rocks]: https://contrib.rocks
[🖐contributors]: https://github.com/oauth-xx/version_gem/graphs/contributors
[🖐contributors-img]: https://contrib.rocks/image?repo=oauth-xx/version_gem
[🚎contributors-gl]: https://gitlab.com/oauth-xx/version_gem/-/graphs/main
[🪇conduct]: CODE_OF_CONDUCT.md
[🪇conduct-img]: https://img.shields.io/badge/Contributor_Covenant-2.1-4baaaa.svg
[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[📌semver]: https://antfu.me/posts/epoch-semver
[📌semver-img]: https://img.shields.io/badge/epoch-semver-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📌changelog]: CHANGELOG.md
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat
[📌gitmoji]:https://gitmoji.dev
[📌gitmoji-img]:https://img.shields.io/badge/gitmoji-%20😜%20😍-FFDD67.svg?style=flat-square
[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[🧮kloc-img]: https://img.shields.io/badge/KLOC-0.117-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue
[🔐security]: SECURITY.md
[🔐security-img]: https://img.shields.io/badge/security-policy-brightgreen.svg?style=flat
[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
[📄license]: LICENSE.txt
[📄license-ref]: https://opensource.org/licenses/MIT
[📄license-img]: https://img.shields.io/badge/License-MIT-green.svg
[📄ilo-declaration]: https://www.ilo.org/declaration/lang--en/index.htm
[📄ilo-declaration-img]: https://img.shields.io/badge/ILO_Fundamental_Principles-✓-brightgreen.svg?style=flat
[🚎yard-current]: http://rubydoc.info/gems/version_gem
[🚎yard-head]: https://rubydoc.info/github/oauth-xx/version_gem/main
[💎stone_checksums]: https://github.com/pboling/stone_checksums
[💎SHA_checksums]: https://gitlab.com/oauth-xx/version_gem/-/tree/main/checksums