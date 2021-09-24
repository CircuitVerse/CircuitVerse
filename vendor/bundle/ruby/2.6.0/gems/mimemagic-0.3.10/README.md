MimeMagic is a library to detect the mime type of a file by extension or by content. It uses the mime database
provided by freedesktop.org (see http://freedesktop.org/wiki/Software/shared-mime-info/).

[![Gem Version](https://img.shields.io/gem/v/mimemagic.svg)](http://rubygems.org/gems/mimemagic)

Dependencies
============

You will require a copy of the Freedesktop.org shared-mime-info database to be available. If you're on Linux,
it's probably available via your package manager, and will probably be in the location it's being looked for
when the gem is installed.

macOS users can install the database via Homebrew with `brew install shared-mime-info`.

Should you be unable to use a package manager you can obtain a copy of the needed file by extracting it from
the Debian package. This process will also work on a Windows machine.

1. Download the package from https://packages.debian.org/sid/amd64/shared-mime-info/download
2. Ensure the command line version of 7-Zip is installed
3. `7z x -so shared-mime-info_2.0-1_amd64.deb data.tar | 7z e -sidata.tar "./usr/share/mime/packages/freedesktop.org.xml"`


Place the file `freedesktop.org.xml` in an appropriate location, and then set the environment variable
`FREEDESKTOP_MIME_TYPES_PATH` to that path. Once that has been done the gem should install successfully. Please
note that the gem will depend upon the file remaining in that location at run time.

Usage
=====

```ruby
require 'mimemagic'
MimeMagic.by_extension('html').text?
MimeMagic.by_extension('.html').child_of? 'text/plain'
MimeMagic.by_path('filename.txt')
MimeMagic.by_magic(File.open('test.html'))
# etc...
```

You can add your own magic with `MimeMagic.add`.

API
===

http://www.rubydoc.info/github/mimemagicrb/mimemagic

Tests
=====

```console
$ bundle install

$ bundle exec rake test
```

Authors
=======

* Daniel Mendler
* Jon Wood
* [MimeMagic Contributors](https://github.com/mimemagicrb/mimemagic/graphs/contributors)

LICENSE
=======

{file:LICENSE MIT}
