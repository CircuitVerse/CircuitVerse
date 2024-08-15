Adds `sort_alphabetical` and `sort_alphabetical_by` to Enumberable(Array/Hash...),
which sorts UTF8 Strings alphabetical.
This sorting is done by placing variants on the same level as base character (A comes before Ä but ÄA comes before AB).

Requirements
=====
 - Ruby >= 1.9

Setup
=====
 - As gem: ` sudo gem install sort_alphabetical `

Usage
=====
    ['b','á'].sort_alphabetical == ['á','b']
    [['b',1],['á',2]].sort_alphabetical_by(&:first) == [['á',2],['b',1]]

    SortAlphabetical.normalize('á') == 'a'

Alternative
===========

Use [ICU](https://github.com/jarib/ffi-icu)
```Ruby
collator = ICU::Collation::Collator.new("nb")
array.sort! { |a,b| collator.compare(a, b) }
```

TODO
====
 - Sort non-ascii-convertables like ß(ss), œ(oe) , ﬁ(fi), see [Ligatures](http://en.wikipedia.org/wiki/Typographical_ligature)
 - Integrate natural sorting e.g. `['a11', 'a2'] => ['a2', 'a11']` like [NaturalSort](https://github.com/johnnyshields/naturalsort)

### [Contributors](https://github.com/grosser/sort_alphabetical/contributors)
=======
 - original string_to_ascii: [Marc-Andre](http://marc-andre.ca/).
 - [Maxime Menant](https://github.com/maxime-menant)
 - [Victor D.](https://github.com/V1c70r)
 - [Andrii Malyshko](https://github.com/nashbridges)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/sort_alphabetical.png)](https://travis-ci.org/grosser/sort_alphabetical)
