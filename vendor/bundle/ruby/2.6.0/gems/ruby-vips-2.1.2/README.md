# ruby-vips

[![Gem Version](https://badge.fury.io/rb/ruby-vips.svg)](https://badge.fury.io/rb/ruby-vips)
[![Test](https://github.com/libvips/ruby-vips/workflows/Test/badge.svg)](https://github.com/libvips/ruby-vips/actions?query=workflow%3ATest)

This gem is a Ruby binding for the [libvips image processing
library](https://libvips.github.io/libvips).

Programs that use `ruby-vips` don't manipulate images directly, instead
they create pipelines of image processing operations building on a source
image. When the end of the pipe is connected to a destination, the whole
pipeline executes at once, streaming the image in parallel from source to
destination a section at a time.  Because `ruby-vips` is parallel, it's quick,
and because it doesn't need to keep entire images in memory, it's light.

## Requirements

  * macOS, Linux, and Windows tested

  * libvips 8.2 or later, see the [libvips install instructions](https://libvips.github.io/libvips/install.html)

  * [ruby-ffi](https://github.com/ffi/ffi) 1.9 or later 

  * Ruby 2.0+, JRuby

## Install

It's just:

```
$ gem install ruby-vips
```

or include it in `Gemfile`:

```ruby
gem "ruby-vips"
```

On Windows, you'll need to set the `RUBY_DLL_PATH` environment variable to 
point to the libvips bin directory.

# Example

```ruby
require "vips"

im = Vips::Image.new_from_file filename

# put im at position (100, 100) in a 3000 x 3000 pixel image, 
# make the other pixels in the image by mirroring im up / down / 
# left / right, see
# https://libvips.github.io/libvips/API/current/libvips-conversion.html#vips-embed
im = im.embed 100, 100, 3000, 3000, extend: :mirror

# multiply the green (middle) band by 2, leave the other two alone
im *= [1, 2, 1]

# make an image from an array constant, convolve with it
mask = Vips::Image.new_from_array [
    [-1, -1, -1],
    [-1, 16, -1],
    [-1, -1, -1]], 8
im = im.conv mask, precision: :integer

# finally, write the result back to a file on disk
im.write_to_file output_filename
```

The `Vips` section in the API docs has a [tutorial introduction with
examples](https://www.rubydoc.info/gems/ruby-vips/Vips).

ruby-vips has [API
 documentation](http://www.rubydoc.info/gems/ruby-vips). The [libvips
 reference manual](https://libvips.github.io/libvips/API/current/) has a
 complete explanation of every method.

The 
[`example/`](https://github.com/libvips/ruby-vips/tree/master/example)
directory has some simple example programs.

# Benchmarks

The benchmark at [vips-benchmarks](https://github.com/jcupitt/vips-benchmarks)
loads a large image, crops, shrinks, sharpens and saves again, and repeats
10 times.

```text
real time in seconds, fastest of five runs
benchmark       tiff    jpeg
ruby-vips.rb	0.85	0.78	
image-magick	2.03	2.44	
rmagick.rb	3.87	3.89	

peak memory use in kb
benchmark	peak RES
ruby-vips.rb	43864
rmagick.rb	788768
```

See also [benchmarks at the official libvips
website](https://github.com/libvips/libvips/wiki/Speed-and-memory-use).

