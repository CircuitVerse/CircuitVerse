---
sidebar_position: 10
---

# PageAssertions


The [PageAssertions](./page_assertions) class provides assertion methods that can be used to make assertions about the [Page](./page) state in the tests.

```ruby
page.content = <<~HTML
<a href="https://example.com/user/login">Sign in</a>
HTML

page.get_by_text("Sign in").click
expect(page).to have_url(/.*\/login/)
```

## not_to_have_title

```
def not_to_have_title(titleOrRegExp, timeout: nil)
```


The opposite of [PageAssertions#to_have_title](./page_assertions#to_have_title).

## not_to_have_url

```
def not_to_have_url(urlOrRegExp, ignoreCase: nil, timeout: nil)
```


The opposite of [PageAssertions#to_have_url](./page_assertions#to_have_url).

## to_have_title

```
def to_have_title(titleOrRegExp, timeout: nil)
```


Ensures the page has the given title.

**Usage**

```ruby
expect(page).to have_title(/.*checkout/)
```

## to_have_url

```
def to_have_url(urlOrRegExp, ignoreCase: nil, timeout: nil)
```


Ensures the page is navigated to the given URL.

**Usage**

```ruby
expect(page).to have_url(/.*checkout/)
```
