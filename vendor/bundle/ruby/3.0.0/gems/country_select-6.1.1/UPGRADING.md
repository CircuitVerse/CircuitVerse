# Upgrading from 1.x

`country_select` 2.0 has brought a few small changes, but these changes
can have a big impact on existing production systems. Please read these
points carefully and consider whether upgrading to 2.0 is a good idea.

Please post any implications we may have missed as a GitHub Issue
or Pull Request.

## ISO codes are always on

If you upgrade to 2.0 and are currently storing countries by the names
produced by this gem, your setup will break. It is recommended that you
stick with 1.x until developing a data migration strategy that allows
you to map your existing country names to country codes.

## i18n country names are always on (when available)

Country names will be generated using `I18n.locale` if a translation
from the countries gem is available.

## Codes are UPCASED

The official ISO 3166-1 standard uses UPCASED codes. This is an easy
data change, but may affect areas of code dependent on lowercase country
codes.

Here's a sample SQL migration that could address a `users` table with
lowercased country codes stored in the `country_code` column:

```sql
UPDATE users SET country_code = UPPER(country_code);
```

## Priority countries are now in the options hash

The priority countries syntax has changed from

```ruby
  country_select(:user, :country_code, ["GB","FR"])
```

to

```ruby
  country_select(:user, :country_code, priority_countries: ["GB","FR"])
```

### A note on 1.x Syntax

In order to seamlessly support popular libraries dependent on
`country_select`, specifically `formatstic` and `simple_form`, 1.x
priority syntax is still supported, but will probably be removed in the
next major release (i.e., 3.0). We'll be working with `simple_form` and
`formtastic` maintainers to transition away from the old 1.x syntax.

## You can choose to only display a chosen set of countries

```ruby
  country_select(:user, :country_code, only: ["LV","SG"])
```

```ruby
  country_select(:user, :country_code, except: ["US","GB"])
```

## Ruby 1.9+

`country_select` will no longer be tested in Ruby `< 1.9`.
