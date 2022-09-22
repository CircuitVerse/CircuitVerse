# Running the Gauntlet

## Maintaining a Gem Mirror

I use rubygems-mirror to keep an archive of all the latest rubygems on
an external disk. Here is the config:

```
---
- from: https://rubygems.org
  to: /Volumes/StuffA/gauntlet/mirror
  parallelism: 10
  retries: 3
  delete: true
  skiperror: true
  hashdir: true
```

And I update using rake:

```
% cd ~/Work/git/rubygems/rubygems-mirror
% git down
% rake mirror:latest
% /Volumes/StuffA/gauntlet/bin/cleanup.rb
```

This rather quickly updates my mirror to the latest versions of
everything and then deletes all old versions. I then run a cleanup
script that fixes the file dates to their publication date and deletes
any gems that have invalid specs. This can argue with the mirror a
bit, but it is pretty minimal (currently ~20 bad gems).

## Curating an Archive of Ruby Files

Next, I process the gem mirror into a much more digestable structure
using `hash.rb` (TODO: needs a better name):

```
% cd RP
% /Volumes/StuffA/gauntlet/bin/unpack_gems.rb
... waaaait ...
% mv hashed.noindex gauntlet.$(today).noindex
% lrztar gauntlet.$(today).noindex
% mv gauntlet.$(today).noindex.lrz /Volumes/StuffA/gauntlet/
```

This script filters all the newer gems (TODO: WHY?), unpacks them,
finds all the files that look like they're valid ruby, ensures they're
valid ruby (using the current version of ruby to compile them), and
then moves them into a SHA dir structure that looks something like
this:

```
hashed.noindex/a/b/c/<full_file_sha>.rb
```

This removes all duplicates and puts everything in a fairly even,
wide, flat directory layout.

This process takes a very long time, even with a lot of
parallelization. There are currently about 160k gems in the mirror.
Unpacking, validating, SHA'ing everything is disk and CPU intensive.
The `.noindex` extension stops spotlight from indexing the continous
churn of files being unpacked and moved and saves time.

Finally, I rename and archive it all up (currently using lrztar, but
I'm not in love with it).

### Stats

```
9696 % find gauntlet.$(today).noindex -type f | lc
  561270
3.5G gauntlet.2021-08-06.noindex
239M gauntlet.2021-08-06.noindex.tar.lrz
```

So I wind up with a little over half a million unique ruby files to
parse. It's about 3.5g but compresses very nicely down to 240m

## Running the Gauntlet

Assuming you're starting from scratch, unpack the archive once:

```
% lrzuntar gauntlet.$(today).noindex.lrz
```

Then, either run a single process (easier to read):

```
% ./gauntlet/bin/gauntlet.rb gauntlet/*.noindex/?
```

Or max out your machine using xargs (note the `-P 16` and choose accordingly):

```
% ls -d gauntlet/*.noindex/?/? | xargs -n 1 -P 16 ./gauntlet/bin/gauntlet.rb
```

In another terminal I usually monitor the progress like so:

```
% while true ; do clear; fd . -t d -t e gauntlet/*.noindex -X rmdir -p 2> /dev/null ; for D in gauntlet/*.noindex/? ; do echo -n "$D: "; fd .rb $D | wc -l ; done ; echo ; sleep 30 ; done
```
