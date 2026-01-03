# HTML Beautifier

A normaliser/beautifier for HTML that also understands embedded Ruby.
Ideal for tidying up Rails templates.

## What it does

* Normalises hard tabs to spaces (or vice versa)
* Removes trailing spaces
* Indents after opening HTML elements
* Outdents before closing elements
* Collapses multiple whitespace
* Indents after block-opening embedded Ruby (if, do etc.)
* Outdents before closing Ruby blocks
* Outdents elsif and then indents again
* Indents the left-hand margin of JavaScript and CSS blocks to match the
  indentation level of the code

## Usage

### From the command line

To update files in-place:

``` sh
$ htmlbeautifier file1.html.erb [file2.html.erb ...]
```

or to operate on standard input and output:

``` sh
$ htmlbeautifier < untidy.html.erb > formatted.html.erb
```

### In your code

```ruby
require 'htmlbeautifier'

beautiful = HtmlBeautifier.beautify(untify_html_string)
```

You can also specify how to indent (the default is two spaces):

```ruby
beautiful = HtmlBeautifier.beautify(untidy_html_string, indent: "\t")
```

## Installation

This is a Ruby gem.
To install the command-line tool (you may need `sudo`):

```sh
$ gem install htmlbeautifier
```

To use the gem with Bundler, add to your `Gemfile`:

```ruby
gem 'htmlbeautifier'
```

## Contributing

1. Follow [these guidelines][git-commit] when writing commit messages (briefly,
   the first line should begin with a capital letter, use the imperative mood,
   be no more than 50 characters, and not end with a period).
2. Include tests.

[git-commit]:http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
