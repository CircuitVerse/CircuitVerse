# ActiveRecordCursorPaginate

This library allows to paginate through an `ActiveRecord` relation using cursor pagination.
It also supports ordering by any column on the relation in either ascending or descending order.

Cursor pagination allows to paginate results and gracefully deal with deletions / additions on previous pages.
Where a regular limit / offset pagination would jump in results if a record on a previous page gets deleted or added while requesting the next page, cursor pagination just returns the records following the one identified in the request.

To learn more about cursor pagination, check out the _"How does it work?"_ section below.

[![Build Status](https://github.com/healthie/activerecord_cursor_paginate/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/healthie/activerecord_cursor_paginate/actions/workflows/test.yml)

## Requirements

- Ruby 2.7+
- Rails (ActiveRecord) 7.0+

If you need support for older ruby and rails, please open an issue.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "activerecord_cursor_paginate"
```

And then run:

```sh
$ bundle install
```

## Usage

Let's assume we have a `Post` model of which we want to fetch some data and then paginate through it.
Therefore, we first apply our scopes, `where` clauses or other functionality as usual:

```ruby
posts = Post.where(author: "Jane")
```

And then we create our paginator to fetch the first response page:

```ruby
paginator = posts.cursor_paginate

# Total number of records to iterate by this paginator
paginator.total_count # => 145

page = paginator.fetch
page.records # => [#<Post:0x00007fd7071b2ea8 @id=1>, #<Post:0x00007fd7071bb738 @id=2>, ..., #<Post:0x00007fd707238260 @id=10>]

# Number of records in this page
page.count # => 10

page.empty? # => false
page.cursors            # => ["MQ", "Mg", ..., "MTA"]
                               |                 |
                               |                 |
page.previous_cursor    # =>  "MQ"               |
page.next_cursor        # =>  "MTA" -------------|
page.has_previous? # => false
page.has_next? # => true
```

Note that any ordering of the relation at this stage will be ignored by the gem.
Take a look at the next section _"Ordering"_ to see how you can have an order different than ascending IDs.

To then get the next result page, you simply need to pass the last cursor of the returned page item via:

```ruby
paginator = posts.cursor_paginate(after: "MTA")
```

This will then fetch the next result page.
You can also just as easily paginate to previous pages by using `before` instead of `after` and using the first cursor of the current page.

```ruby
paginator = posts.cursor_paginate(before: "MQ")
```

By default, this will always return up to 10 results. But you can also specify how many records should be returned via `limit` parameter.

```ruby
paginator = posts.cursor_paginate(after: "MTA", limit: 2)
```

```ruby
paginator = posts.cursor_paginate(before: "MQ", limit: 2)
```

You can also easily iterate over the whole relation:

```ruby
paginator = posts.cursor_paginate

# Will lazily iterate over the pages.
paginator.pages.each do |page|
  # do something with the page
end
```

### Ordering

As said, this gem ignores any previous ordering added to the passed relation.
But you can still paginate through relations with an order different than by ascending IDs.

You can specify a different column and direction to order the results by via an `order` parameter.

```ruby
# Order records ascending by the `:author` field.
paginator = posts.cursor_paginate(order: :author)

# Order records descending by the `:author` field.
paginator = posts.cursor_paginate(order: { author: :desc })

# Order records ascending by the `:author` and `:title` fields.
paginator = posts.cursor_paginate(order: [:author, :title])

# Order records ascending by the `:author` and descending by the `:title` fields.
paginator = posts.cursor_paginate(order: { author: :asc, title: :desc })
```

The gem implicitly appends a primary key column to the list of sorting columns. It may be useful
to disable it for the table with a UUID primary key or when the sorting is done by a combination
of columns that are already unique.

```ruby
paginator = UserSettings.cursor_paginate(order: :user_id, append_primary_key: false)
```

**Important:**
If your app regularly orders by another column, you might want to add a database index for this.
Say that your order column is `author` then you'll want to add a compound index on `(author, id)`.
If your table is called `posts` you can use a query like this in MySQL or PostgreSQL:

```sql
CREATE INDEX index_posts_on_author_and_id ON posts (author, id)
```

Or you can just do it via an `ActiveRecord::Migration`:

```ruby
class AddAuthorAndIdIndexToPosts < ActiveRecord::Migration[7.1]
  def change
    add_index :posts, [:author, :id]
  end
end
```

Take a look at the _"How does it work?"_ to find out more why this is necessary.

#### Ordering and `JOIN`s

To order by a column from the `JOIN`ed table, you need to explicitly specify and fully qualify the column name for the `:order` parameter:

```ruby
paginator = User.joins(:projects).cursor_paginate(order: [Arel.sql("projects.id"), :id])
page = paginator.fetch
```

**Note**: Make sure to wrap custom SQL expressions by `Arel.sql`.

#### Order by more complex logic

Sometimes you might not only want to order by a column ascending or descending, but need more complex logic.
Imagine you would also store the post's `category` on the `posts` table (as a plain string for simplicity's sake).
And the category could be `pinned`, `announcement`, or `general`.
Then you might want to show all `pinned` posts first, followed by the `announcement` ones and lastly show the `general` posts.

In MySQL you could e.g. use a `FIELD(category, 'pinned', 'announcement', 'general')` query in the `ORDER BY` clause to achieve this.
However, you cannot add an index to such a statement. And therefore, the performance of this is pretty dismal.

The gem supports ordering by custom SQL expressions, but make sure the performance will not suffer.

What is recommended if you _do_ need to order by more complex logic is to have a separate column that you only use for ordering.
You can use `ActiveRecord` hooks to automatically update this column whenever you change your data.
Or, for example in MySQL, you can also use a [generated column](https://dev.mysql.com/doc/refman/5.7/en/create-table-generated-columns.html) that is automatically being updated by the database based on some stored logic.

For example, if you want paginate `users` by a lowercased `email`, you can use the following:

```ruby
paginator = User.cursor_paginate(order: Arel.sql("lower(email)"))
page = paginator.fetch
```

**Note**: Make sure to wrap custom SQL expressions by `Arel.sql`.

### Configuration

You can change the default page size to a value that better fits the needs of your application.
So if a user doesn't request a given `:limit` value, the default amount of records is being returned.

To change the default, simply add an initializer to your app that does the following:

```ruby
# config/initializers/activerecord_cursor_paginate.rb
ActiveRecordCursorPaginate.configure do |config|
  config.default_page_size = 50
end
```

This would set the default page size to 50.

You can also set a global `max_page_size` to prevent a client from requesting too large pages.

```ruby
ActiveRecordCursorPaginate.configure do |config|
  config.max_page_size = 100
end
```

## How does it work?

This library allows to paginate through a passed relation using a cursor
for before or after parameters. It also supports ordering by any column
on the relation in either ascending or descending order.

Cursor pagination allows to paginate results and gracefully deal with
deletions / additions on previous pages. Where a regular limit / offset
pagination would jump in results if a record on a previous page gets deleted
or added while requesting the next page, cursor pagination just returns the
records following the one identified in the request.

How this works is that it uses a "cursor", which is an encoded value that
uniquely identifies a given row for the requested order. Then, based on
this cursor, you can request the "n records AFTER the cursor"
(forward-pagination) or the "n records BEFORE the cursor" (backward-pagination).

As an example, assume we have a table called "posts" with this data:

| id | author |
|----|--------|
| 1  | Jane   |
| 2  | John   |
| 3  | John   |
| 4  | Jane   |
| 5  | Jane   |
| 6  | John   |
| 7  | John   |

Now if we make a basic request without any `before`, `after`, custom `order` column,
this will just request the first page of this relation.

```ruby
paginator = relation.cursor_paginate
page = paginator.fetch
```

Assume that our default page size here is 2 and we would get a query like this:

```sql
SELECT *
FROM posts
ORDER BY id ASC
LIMIT 2
```

This will return the first page of results, containing post #1 and #2. Since
no custom order is defined, each item in the returned collection will have a
cursor that only encodes the record's ID.

If we want to now request the next page, we can pass in the cursor of record
#2 which would be `"Mg"` (can get via `page.cursor`). So now we can request
the next page by calling:

```ruby
paginator = relation.cursor_paginate(limit: 2, after: "Mg")
page = paginator.fetch
```

And this will decode the given cursor and issue a query like:

```sql
SELECT *
FROM posts
WHERE id > 2
ORDER BY id ASC
LIMIT 2
```

Which would return posts #3 and #4. If we now want to paginate back, we can
request the posts that came before the first post, whose cursor would be
`"Mw"` (can get via `page.previous_cursor`):

```ruby
paginator = relation.cursor_paginate(limit: 2, before: "Mw")
page = paginator.fetch
```

Since we now paginate backward, the resulting SQL query needs to be flipped
around to get the last two records that have an ID smaller than the given one:

```sql
SELECT *
FROM posts
WHERE id < 3
ORDER BY id DESC
LIMIT 2
```

This would return posts #2 and #1. Since we still requested them in
ascending order, the result will be reversed before it is returned.

Now, in case that the user wants to order by a column different than the ID,
we require this information in our cursor. Therefore, when requesting the
first page like this:

```ruby
paginator = relation.cursor_paginate(order: :author)
page = paginator.fetch
```

This will issue the following SQL query:

```sql
SELECT *
FROM posts
ORDER BY author ASC, id ASC
LIMIT 2
```

As you can see, this will now order by the author first, and if two records
have the same author it will order them by ID. Ordering only the author is not
enough since we cannot know if the custom column only has unique values.
And we need to guarantee the correct order of ambiguous records independent
of the direction of ordering. This unique order is the basis of being able
to paginate forward and backward repeatedly and getting the correct records.

The query will then return records #1 and #4. But the cursor for these
records will also be different to the previous query where we ordered by ID
only. It is important that the cursor encodes all the data we need to
uniquely identify a row and filter based upon it. Therefore, we need to
encode the same information as we used for the ordering in our SQL query.
Hence, the cursor for pagination with a custom column contains a tuple of
data, the first record being the custom order column followed by the
record's ID.

Therefore, the cursor of record #4 will encode `['Jane', 4]`, which yields
this cursor: `"WyJKYW5lIiw0XQ"`.

If we now want to request the next page via:

```ruby
paginator = relation.cursor_paginate(order: :author, limit: 2, after: "WyJKYW5lIiw0XQ")
page = paginator.fetch
```

We get this SQL query:

```sql
SELECT *
FROM posts
WHERE (author > 'Jane' OR (author = 'Jane') AND (id > 4))
ORDER BY author ASC, id ASC
LIMIT 2
```

You can see how the cursor is being used by the WHERE clause to uniquely
identify the row and properly filter based on this. We only want to get
records that either have a name that is alphabetically after `"Jane"` or
another `"Jane"` record with an ID that is higher than `4`. We will get the
records #5 and #2 as response.

When using a custom `order`, this affects both filtering as well as
ordering. Therefore, it is recommended to add an index for columns that are
frequently used for ordering. In our test case we would want to add a compound
index for the `(author, id)` column combination. Databases like MySQL and
PostgreSQL are able to then use the leftmost part of the index, in our case
`author`, by its own or can use it combined with the `id` index.

## Credits

Thanks to [rails_cursor_pagination gem](https://github.com/xing/rails_cursor_pagination) for the original ideas.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the linter and tests. This project uses multiple Gemfiles to test against multiple versions of Active Record; you can run the tests against the specific version with `BUNDLE_GEMFILE=gemfiles/activerecord_71.gemfile bundle exec rake test`.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/healthie/activerecord_cursor_paginate.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
