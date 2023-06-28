- [LanguageFilter](#languagefilter)
  - [About](#about)
  - [Guiding Principles](#guiding-principles)
  - [TO-DO](#to-do)
  - [Installation](#installation)
  - [Usage](#usage)
    - [`:matchlist` and `:exceptionlist`](#matchlist-and-exceptionlist)
      - [Symbol signifying a pre-packaged list](#symbol-signifying-a-pre-packaged-list)
      - [An array of words and phrases to screen for](#an-array-of-words-and-phrases-to-screen-for)
      - [A filepath or string pointing to a filepath](#a-filepath-or-string-pointing-to-a-filepath)
        - [Formatting your lists](#formatting-your-lists)
    - [`:replacement`](#replacement)
    - [`:creative_letters`](#creative_letters)
    - [Methods to modify filters after creation](#methods-to-modify-filters-after-creation)
    - [ActiveModel integration](#activemodel-integration)
  - [Contributing](#contributing)


# LanguageFilter

## About

LanguageFilter is a Ruby gem to detect and optionally filter multiple categories of language. It was adapted from Thiago Jackiw's Obscenity gem for [FractalWriting.org](http://fractalwriting.org) and features many improvements, including:

- The ability to create and independently configure multiple language filters.
- Comes pre-packaged with multiple matchlists (for hate, profanity, sex, and violence), for more fine-tuned language detection. I think this aligns much better with the real needs of communities that might need language filtering. For example, I probably want to flag and eventually ban users that use hateful language. Then for content featuring sex, profanity, and/or violence, I can let users know exactly what to expect before delving into content, much more so than with a single, all-encompassing "mature" tag.
- Simpler, more intuitive configuration.
- More neutral language to accommodate a wider variety of use cases. For example, LanguageFilter uses `matchlist` and `exceptionlist` instead of `blacklist` and `whitelist`, since the gem can be used not only for censorship, but also for content *type* identification (e.g. fantasy, sci-fi, historical, etc in the context of creative writing)
- More robust exceptionlist (i.e. whitelist) handling. Given a simple example of a matchlist containing `cock` and an exceptionlist containing `game cock`, the other filtering gems I've seen will flag the `cock` in `game cock`, despite the exceptionlist. LanguageFilter is a little smarter and does what you would expect, so that when sanitizing the string `cock is usually sexual, but a game cock is just an animal`, the returned string will be `**** is usually sexual, but a game cock is just an animal`.

It should be noted however, that if you'd like to use this gem or another language filtering library to replace human moderation, you should not, for [reasons outlined here](http://www.codinghorror.com/blog/2008/10/obscenity-filters-bad-idea-or-incredibly-intercoursing-bad-idea.html). The major takeaway is that content filtering is a very difficult problem and context is everything. You can keep refining your filters, but that can easily become a full-time job and it can be difficult to do these refinements without unintentionally creating more false positives, which is extremely frustrating from a user's point of view. This kind of tool is best used to *guide* users, rather than enforce rules on them. See the guiding principles below for more on this.

## Guiding Principles

These are things I've learned from developing this gem that are good to keep in mind when using or contributing to the project.

**It's better to under-match than over-match.**

It's extremely frustrating, for example, if someone is prevented from entering a perfectly good username that just happens to contain the word "ass" in it - as many do. It's not nearly as frustrating to be exposed to profanity that you have to strain to make out.

**Using filters for language detection that aid in self-categorization is a better idea than automatically forcing mature/profane/sexual/etc tags on user-generated content.**

If someone uses language that could be considered profanity in many contexts, but is not profanity in their particular context, such as "bitch" to describe a female dog or "ass" to describe a donkey, they will be justifiably upset at the automatic categorization. It's better to say, "Your story contains the following words or phrases that we think might be profane: bitch, ass. Click on the `profane` tag if you'd like to add it." Then other users can flag content that still isn't correctly categorized and moderators can edit content tags and educate the user to further prevent miscategorization.

## TO-DO

- Expand the pre-packaged matchlists to be more exhaustive
- Add some activemodel integration, a la something like:

``` ruby
filter_language :content, matchlist: :hate, replacement: :garbled
validate_language :username, matchlist: :profanity
```

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'language_filter'
```

And then execute:

``` bash
$ bundle
```

Or install it yourself as:

``` bash
$ gem install language_filter
```

## Usage

Need a new language filter? Here's a quick usage example:

``` ruby
sex_filter = LanguageFilter::Filter.new matchlist: :sex, replacement: :stars

# returns true if any content matched the filter's matchlist, else false
sex_filter.match?('This is some sexual content.')
=> true

# returns a "cleaned up" version of the text, based on the replacement rule
sex_filter.sanitize('This is some sexual content.')
=> "This is some ****** content."

# returns an array of the words and phrases that matched an item in the matchlist
sex_filter.matched('This is some sexual content.')
=> ["sexual"]
```

Now let's go over this a little more methodically. When you create a new LanguageFilter, you simply call LanguageFilter::Filter.new, with any of the following optional parameters. Below, you can see their defaults.

``` ruby
LanguageFilter::Filter.new(
                            matchlist: :profanity,
                            exceptionlist: [],
                            replacement: :stars
                          )
```

Now let's dive a little deeper into each parameter.

### `:matchlist` and `:exceptionlist`

Both of these lists can take four different kinds of inputs.

#### Symbol signifying a pre-packaged list

By default, LanguageFilter comes with four different matchlists, each screening for a different category of language. These filters are accessible via:

- `matchlist: :hate` (for hateful language, like `f**k you`, `b***h`, or `f*g`)
- `matchlist: :profanity` (for swear/cuss words and phrases)
- `matchlist: :sex` (for content of a sexual nature)
- `matchlist: :violence` (for language indicating violence, such as `stab`, `gun`, or `murder`)

There's quite a bit of overlap between these lists, but they can be useful for communities that may want to self-monitor, giving them an idea of the kind of content in a story or article before clicking through.

#### An array of words and phrases to screen for

- `matchlist: ['giraffes?','rhino\w*','elephants?'] # a non-exhaustive list of African animals`

As you may have noticed, you can include regex! However, if you do, keep in mind that the more complicated regex you include, the slower the matching will be. Also, if you're assigning an array directly to matchlist and want to use regex, be sure to use single quotes (`'like this'`), rather than double quotes (`"like this"`). Otherwise, Ruby will think your backslashes are to help it interpolate the string, rather than to be intrepreted literally and passed into your regex, untouched.

In the actual matching, each item you enter in the list is dumped into the middle of the following regex, through the `list_item` variable.

``` ruby
/\b#{list_item}\b/i
```

There's not a whole lot going on there, but I'll quickly parse it for any who aren't very familiar with regex.

- `#{list_item}` just dumps in the item from our list that we want to check.
- The two `\b` on either side ensure that only text surrounded by non-word characters (anything other than letters, numbers, and the underscore), or the beginning or end of a string, are matched.
- The two `/` wrapping (almost) the whole statement lets Ruby know that this is a regex statement.
- The `i` right after the regex tells it to match case-insensitively, so that whether someone writes `giraffe`, `GIRAFFE`, or `gIrAffE`, the match won't fail.

If you'd like to master some regex Rubyfu, I highly recommend stopping at [Rubular.com](http://rubular.com/).

#### A filepath or string pointing to a filepath

If you want to use your own lists, there are two ways to do it.

1) Pass in a filepath:

``` ruby
matchlist: File.join(Rails.root,"/config/language_filters/my_custom_list.yml")
```

2) Pass in a `Pathname`, like Rails.root. I'm honestly not sure when you'd do this, but it was in option in Obscenity and it's still an option now.

##### Formatting your lists

Now when you're actually writing these lists, they both use the same, relatively simple format, which looks something like this:

``` regex
giraffes?
rhino\w*
elephants?
```

It's a pretty simple pattern. Each word, phrase, or regex is on its own line - and that's it.

### `:replacement`

If you're not using this gem to filter out potentially offensive content, then you don't have to worry about this part. For the rest of you the `:replacement` parameter specifies what to replace matches with, when sanitizing text.

Here are the options:

`replacement: :stars` (this is the default replacement method)

Example: This is some ****** up ****.

`replacement: :garbled`

Example: This is some $@!#% up $@!#%.

`replacement: :vowels`

Example: This is some f*ck*d up sh*t.

`replacement: :nonconsonants` (useful where letters might be replaced with numbers, for example in L3375P34|< - i.e. leetspeak)

Example: 7|-|1$ 1$ $0/\/\3 Ph*****D UP ******.

(**note: `creative_letters: true` must be set to match plain words to leetspeak**)

### `:creative_letters`

If you want to match leetspeak or other creative lettering, figuring out all the possible variations of each letter in a word can be exhausting. *And* you don't want to go through the whole process for each and every word, creating complicated matchlists that humans will struggle to parse.

That's why there's a :creative_letters option. When set to true, your filter will use a version of your matchlist that will catch common and not-so-common letterings for each word in your matchlist. The downside to this option is a significant hit to performance.

Here's an example. Let's say you have a matchlist with a single word:

```
hippopotamus
```

But what if some smart-allec types in something like this?

```
}{!|o|o[]|o()+4|\/|v$
```

Well, if you have :creative_letters activated, the matchlist that your filtering engine will actually use looks more like this:

```
(?:(?:h|\\#|[\\|\\}\\{\\\\/\\(\\)\\[\\]]\\-?[\\|\\}\\{\\\\/\\(\\)\\[\\]])+)(?:(?:i|l|1|\\!|\\u00a1|\\||\\]|\\[|\\\\|/|[^a-z]eye[^a-z]|\\u00a3|[\\|li1\\!\\u00a1\\[\\]\\(\\)\\{\\}]_|\\u00ac|[^a-z]el+[^a-z]))(?:(?:p|\\u00b6|[\\|li1\\[\\]\\!\\u00a1/\\\\][\\*o\\u00b0\\\"\\>7\\^]|[^a-z]pee+[^a-z])+)(?:(?:p|\\u00b6|[\\|li1\\[\\]\\!\\u00a1/\\\\][\\*o\\u00b0\\\"\\>7\\^]|[^a-z]pee+[^a-z])+)(?:(?:o|0|\\(\\)|\\[\\]|\\u00b0|[^a-z]oh+[^a-z])+)(?:(?:p|\\u00b6|[\\|li1\\[\\]\\!\\u00a1/\\\\][\\*o\\u00b0\\\"\\>7\\^]|[^a-z]pee+[^a-z])+)(?:(?:o|0|\\(\\)|\\[\\]|\\u00b0|[^a-z]oh+[^a-z])+)(?:(?:t|7|\\+|\\u2020|\\-\\|\\-|\\'\\]\\[\\')+)(?:(?:a|@|4|\\^|/\\\\|/\\-\\\\|aye?)+)(?:(?:m|[\\|\\(\\)/](?:\\\\/|v|\\|)[\\|\\(\\)\\\\]|\\^\\^|[^a-z]em+[^a-z])+)(?:(?:u|v|\\u00b5|[\\|\\(\\)\\[\\]\\{\\}]_[\\|\\(\\)\\[\\]\\{\\}]|\\L\\||\\/|[^a-z]you[^a-z]|[^a-z]yoo+[^a-z]|[^a-z]vee+[^a-z]))(?:(?:s|\\$|5|\\u00a7|[^a-z]es+[^a-z]|z|2|7_|\\~/_|\\>_|\\%|[^a-z]zee+[^a-z])+)
```

And that barely legible mess can be made completely illegible by the `sanitize` method. Even *this* crazy string of regex can be beaten though. People *will* have to get quite creative, but people *are* creative. And making it difficult to enter banned content can make it quite an attractive challenge. For this reason and because of the aforementioned performance hit, **this option is not recommended for production systems**.

### Methods to modify filters after creation

If you ever want to change the matchlist, exceptionlist, or replacement type, each parameter is accessible via an assignment method.

For example:

``` ruby
my_filter = LanguageFilter::Filter.new(
                                        matchlist: ['dogs?'], 
                                        exceptionlist: ['dogs drool'],
                                        replacement: :garbled
                                      )

my_filter.sanitize('Dogs rule, cats drool!')
=> "$@!#% rule, cats drool!"
my_filter.sanitize('Cats rule, dogs drool!')
=> "Cats rule, dogs drool!"

my_filter.matchlist = ['dogs?','cats drool']
my_filter.exceptionlist = ['dogs drool','dogs are cruel']
my_filter.replacement = :stars

my_filter.sanitize('Dogs rule, cats drool!')
=> "**** rule, **********!"
my_filter.sanitize('Cats rule, dogs drool!')
=> "Cats rule, dogs drool!"
```

In the above case though, we just wanted to add items to the existing lists, so there's actually a better solution. They're stored as arrays, so treat them as such. Any array methods are fair game.

For example:

``` ruby
my_filter.matchlist.pop
my_filter.matchlist << "cats are liars" << "don't listen to( the)? cats" << "why does no one heed my warnings about the cats?! aren't you getting my messages?"
my_filter.matchlist.uniq!
# etc...
```

### ActiveModel integration

There's not yet any built-in ActiveModel integration, but that doesn't mean it isn't a breeze to work with filters in your model. The examples below should help get you started.

```ruby
# garbles any hateful language in the content attribute before any save to the database
before_save :remove_hateful_language

def remove_hateful_language
  hate_filter = LanguageFilter::Filter.new matchlist: :hate, replacement: :garbled
  content = hate_filter.sanitize(content)
end
````

``` ruby
# yells at users if they try to sneak in a dirty username, letting them know exactly why the username they wanted was rejected
validate :clean_username 

def clean_username
  profanity_filter = LanguageFilter::Filter.new matchlist: :profanity
  if profanity_filter.match? username then
    errors.add(:username, "The following language is inappropriate in a username: #{profanity_filter.matched(username).join(', ')}"
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
