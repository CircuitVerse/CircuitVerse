New for 1.1.1:

* Fix specs flaking due to leaky path and runner
* Use String.new to create a mutable string

New for 1.1.0:

* Remove Travis CI configuration
* Fix the stderr test
* Add Ruby 3.3, 3.4 to the build matrix
* Upgrade actions/checkout from v2 to v4
* Upgrade JRuby to 9.4.12.0
* Insert an inspect on the exit status
* Don't hang on stderr
* Add 'logger' as development dependency (fixes ruby 3.4 warning)
* Use String.new to create a mutable string

New for 1.0.1:

* Relax version requirement for `climate_control` dependency

New for 1.0.0:

* Terrapin::CommandLine::PosixRunner was removed. You can replace any usage of this with Terrapin::CommandLine::ProcessRunner, which uses Ruby’s builtin Process.spawn.
* Moved CI from Travis to GH Actions.

New for 0.6.0:

* Rename the project to Terrapin

New for 0.5.8:

* Improvement: Ensure that argument interpolations can be turned into Strings
* Feature: Save STDOUT and STDERR for inspection when the command completes
* Bug fix: Properly interpolate at the end of the line

New for 0.5.7:

* Feature: Allow collection of both STDOUT and STDERR.
* Improvement: Convert arguments to strings when possible

New for 0.5.6:

* Bug Fix: Java does not need to run commands with `env`
* Bug Fix: Found out we were rescuing the wrong error

New for 0.5.5:

* Bug Fix: Posix- and ProcessRunner respect paths *and* are thread safe!
* Bug Fix: `exitstatus` should always be set, even if command doesn't run.
* Test Fix: Do not try to test Runners if they don't run on this system.
* Improvement: Pass the Errno::ENOENT message through to the exception.
* Improvement: Improve documentation

New for 0.5.4:

* Bug Fix: PosixRunner and ProcessRunner respect supplemental paths now.

New for 0.5.3:

* SECURITY: Fix exploitable bug that could allow arbitrary command execution.
  See CVE-2013-4457 for more details. Thanks to Holger Just for report and fix!
* Bug fix: Sub-word interpolations can be confused for the longer version

New for 0.5.2:

* Improvement: Close all the IO objects!
* Feature: Add an Runner that uses IO.popen, so JRuby can play
* Improvement: Officially drop Ruby 1.8 support, add Ruby 2.0 support
* Bug fix: Prevent a crash if no command was actually run
* Improvement: Add security cautions to the README

New for 0.5.1:

* Fixed a bug preventing running on 1.8.7 for no good reason.

New for 0.5.0:

* Updated the copyrights to 2013
* Added UTF encoding markers on code files to ensure they're interpreted as
  UTF-8 instead of ASCII.
* Swapped the ordering of the PATH and supplemental path. A binary in the
  supplemental path will take precedence, now.
* Errors contain the output of the erroring command, for inspection.
* Use climate_control instead for environment management.

New for 0.4.2:

* Loggers that don't understand `tty?`, like `ActiveSupport::BufferedLogger`
  will still work.

New for 0.4.1:

* Introduce FakeRunner for testing, so you don't really run commands.
* Fix logging: output the actual command, not the un-interpolated pattern.
* Prevent color codes from being output if log destination isn't a TTY.

New for 0.4.0:

* Moved interpolation to the `run` method, instead of interpolating on `new`.
* Remove official support for REE.

New for 0.3.2:

* Fix a hang when processes wait for IO.

New for 0.3.1:

* Made the `Runner` manually swappable, in case `ProcessRunner` doesn't work
  for some reason.
* Fixed copyright years.

New for 0.3.0:

* Support blank arguments.
* Add `CommandLine#unix?`.
* Add `CommandLine#exit_status`.
* Automatically use `POSIX::Spawn` if available.
* Add `CommandLine#environment` as a hash of extra `ENV` data..
* Add `CommandLine#runner` which produces an object that responds to `#call`.
* Fix a race condition but only on Ruby 1.9.
