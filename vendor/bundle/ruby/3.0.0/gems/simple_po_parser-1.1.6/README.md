# Simple Po Parser

[![Build Status](https://travis-ci.org/experteer/simple_po_parser.svg?branch=master)](https://travis-ci.org/experteer/simple_po_parser)
[![Coverage Status](https://img.shields.io/coveralls/experteer/simple_po_parser.svg)](https://coveralls.io/github/experteer/simple_po_parser)
[![Gem Version](https://badge.fury.io/rb/simple_po_parser.svg)](https://badge.fury.io/rb/simple_po_parser)

This is a simple PO file to ruby hash parser, which complies with [GNU PO file specification](https://www.gnu.org/software/gettext/manual/html_node/PO-Files.html). Tested with the msgcat (GNU gettext-tools) 0.18.3 tool.

The parser is probably as optimized for speed as possible with pure ruby, while parsing all different PO types into seperate keys. It was written as a "core-replacement" for an equivalent parslet PEG parser for [arashm/PoParser](https://github.com/arashm/PoParser) and benchmarked about 500 times faster.

## Usage

The parser can be used in two ways:

```ruby
SimplePoParser.parse(file_path) # parses a PO file and returns array of hashes

SimplePoParser.parse_message(message) # parses a single PO message and returns a hash
```

### Hash format

A PO message is parsed into a hash with meaningful keys for each type of line.
 The values are strings if only one line of such content was parsed,
 otherwise it's an array of strings. Each string is
 representing one line of content in the PO file.

```ruby
{
  :translator_comment => "" || ["", ""...],
  :extracted_comment => "" || ["", ""...],
  :reference => "" || ["", ""...],
  :flag => "" || ["", ""...],
  :previous_msgctxt => "" || ["", ""...],# msgctxt of the message used for the fuzzy translation
  :previous_msgid => "" || ["", ""...], # msgid of the messaged used for the fuzzy translation
  :previous_msgid_plural => "" || ["", ""...],
  :msgctxt => "" || ["", ""...],
  :msgid => "" || ["", ""...],
  :msgid_plural => "" || ["", ""...],
  :msgstr => "" || ["", ""...], # for singular messages
  "msgstr[N]" => "" || ["", ""...] # for plural messages, there N is the plural number starting from 0
}
```

## License

License: [MIT](LICENSE.txt) - Copyright (c) 2017 Dennis-Florian Herr @Experteer GmbH
