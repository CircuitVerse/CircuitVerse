## master (unreleased)

## 0.4.1 (2025-04-08)

- Fix `Paginator#total_count` to not change when paginating
- Fix `Paginator#limit` to return default page size by default

## 0.4.0 (2025-03-10)

- Add ability to paginate backward from the end of the collection

    ```ruby
    paginator = users.cursor_paginate(forward_pagination: false)
    ```

## 0.3.0 (2025-01-06)

- Allow paginating over nullable columns

    Previously, the error was raised when cursor values contained `nil`s. Now, it is possible to paginate
    over columns containing `nil` values. You need to explicitly configure which columns are nullable,
    otherwise columns are considered as non-nullable by the gem.

    ```ruby
    paginator = users.cursor_paginate(order: [:name, :id], nullable_columns: [:name])
    ```

    Note that it is not recommended to use this feature, because the complexity of produced SQL queries can have
    a very negative impact on the database performance. It is better to paginate using only non-nullable columns.

- Fix paginating over relations with joins, includes and custom ordering
- Add ability to incrementally configure a paginator

- Add ability to get the total number of records

    ```ruby
    paginator = posts.cursor_paginate
    paginator.total_count # => 145
    ```

## 0.2.0 (2024-05-23)

- Fix prefixing selected columns when iterating over joined tables
- Change cursor encoding to url safe base64
- Fix `next_cursor`/`previous_cursor` for empty pages
- Fix iterating using only a timestamp column

- Add the ability to skip implicitly appending a primary key to the list of sorting columns.

    It may be useful to disable it for the table with a UUID primary key or when the sorting
    is done by a combination of columns that are already unique.

    ```ruby
    paginator = UserSettings.cursor_paginate(order: :user_id, append_primary_key: false)
    ```

## 0.1.0 (2024-03-08)

- First release
