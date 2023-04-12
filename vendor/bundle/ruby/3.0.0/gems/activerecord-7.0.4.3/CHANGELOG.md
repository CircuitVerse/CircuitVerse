## Rails 7.0.4.3 (March 13, 2023) ##

*   No changes.


## Rails 7.0.4.2 (January 24, 2023) ##

*   No changes.


## Rails 7.0.4.1 (January 17, 2023) ##

*   Make sanitize_as_sql_comment more strict

    Though this method was likely never meant to take user input, it was
    attempting sanitization. That sanitization could be bypassed with
    carefully crafted input.

    This commit makes the sanitization more robust by replacing any
    occurrances of "/*" or "*/" with "/ *" or "* /". It also performs a
    first pass to remove one surrounding comment to avoid compatibility
    issues for users relying on the existing removal.

    This also clarifies in the documentation of annotate that it should not
    be provided user input.

    [CVE-2023-22794]

*   Added integer width check to PostgreSQL::Quoting

    Given a value outside the range for a 64bit signed integer type
    PostgreSQL will treat the column type as numeric. Comparing
    integer values against numeric values can result in a slow
    sequential scan.

    This behavior is configurable via
    ActiveRecord::Base.raise_int_wider_than_64bit which defaults to true.

    [CVE-2022-44566]


## Rails 7.0.4 (September 09, 2022) ##

*   Symbol is allowed by default for YAML columns

    *Étienne Barrié*

*   Fix `ActiveRecord::Store` to serialize as a regular Hash

    Previously it would serialize as an `ActiveSupport::HashWithIndifferentAccess`
    which is wasteful and cause problem with YAML safe_load.

    *Jean Boussier*

*   Add `timestamptz` as a time zone aware type for PostgreSQL

    This is required for correctly parsing `timestamp with time zone` values in your database.

    If you don't want this, you can opt out by adding this initializer:

    ```ruby
    ActiveRecord::Base.time_zone_aware_types -= [:timestamptz]
    ```

    *Alex Ghiculescu*

*   Fix supporting timezone awareness for `tsrange` and `tstzrange` array columns.

    ```ruby
    # In database migrations
    add_column :shops, :open_hours, :tsrange, array: true
    # In app config
    ActiveRecord::Base.time_zone_aware_types += [:tsrange]
    # In the code times are properly converted to app time zone
    Shop.create!(open_hours: [Time.current..8.hour.from_now])
    ```

    *Wojciech Wnętrzak*

*   Resolve issue where a relation cache_version could be left stale.

    Previously, when `reset` was called on a relation object it did not reset the cache_versions
    ivar. This led to a confusing situation where despite having the correct data the relation
    still reported a stale cache_version.

    Usage:

    ```ruby
    developers = Developer.all
    developers.cache_version

    Developer.update_all(updated_at: Time.now.utc + 1.second)

    developers.cache_version # Stale cache_version
    developers.reset
    developers.cache_version # Returns the current correct cache_version
    ```

    Fixes #45341.

    *Austen Madden*

*   Fix `load_async` when called on an association proxy.

    Calling `load_async` directly an association would schedule
    a query but never use it.

    ```ruby
    comments = post.comments.load_async # schedule a query
    comments.to_a # perform an entirely new sync query
    ```

    Now it does use the async query, however note that it doesn't
    cause the association to be loaded.

    *Jean Boussier*

*   Fix eager loading for models without primary keys.

    *Anmol Chopra*, *Matt Lawrence*, and *Jonathan Hefner*

*   `rails db:schema:{dump,load}` now checks `ENV["SCHEMA_FORMAT"]` before config

    Since `rails db:structure:{dump,load}` was deprecated there wasn't a simple
    way to dump a schema to both SQL and Ruby formats. You can now do this with
    an environment variable. For example:

    ```
    SCHEMA_FORMAT=sql rake db:schema:dump
    ```

    *Alex Ghiculescu*

*   Fix Hstore deserialize regression.

    *edsharp*


## Rails 7.0.3.1 (July 12, 2022) ##

*   Change ActiveRecord::Coders::YAMLColumn default to safe_load

    This adds two new configuration options The configuration options are as
    follows:
    
    * `config.active_storage.use_yaml_unsafe_load`
    
    When set to true, this configuration option tells Rails to use the old
    "unsafe" YAML loading strategy, maintaining the existing behavior but leaving
    the possible escalation vulnerability in place.  Setting this option to true
    is *not* recommended, but can aid in upgrading.
    
    * `config.active_record.yaml_column_permitted_classes`
    
    The "safe YAML" loading method does not allow all classes to be deserialized
    by default.  This option allows you to specify classes deemed "safe" in your
    application.  For example, if your application uses Symbol and Time in
    serialized data, you can add Symbol and Time to the allowed list as follows:
    
    ```
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time]
    ```

    [CVE-2022-32224]


## Rails 7.0.3 (May 09, 2022) ##

*   Some internal housekeeping on reloads could break custom `respond_to?`
    methods in class objects that referenced reloadable constants. See
    [#44125](https://github.com/rails/rails/issues/44125) for details.

    *Xavier Noria*

*   Fixed MariaDB default function support.

    Defaults would be written wrong in "db/schema.rb" and not work correctly
    if using `db:schema:load`. Further more the function name would be
    added as string content when saving new records.

    *kaspernj*

*   Fix `remove_foreign_key` with `:if_exists` option when foreign key actually exists.

    *fatkodima*

*   Remove `--no-comments` flag in structure dumps for PostgreSQL

    This broke some apps that used custom schema comments. If you don't want
    comments in your structure dump, you can use:

    ```ruby
    ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
    ```

    *Alex Ghiculescu*

*   Use the model name as a prefix when filtering encrypted attributes from logs.

    For example, when encrypting `Person#name` it will add `person.name` as a filter
    parameter, instead of just `name`. This prevents unintended filtering of parameters
    with a matching name in other models.

    *Jorge Manrubia*

*   Fix quoting of `ActiveSupport::Duration` and `Rational` numbers in the MySQL adapter.

    *Kevin McPhillips*

*   Fix `change_column_comment` to preserve column's AUTO_INCREMENT in the MySQL adapter

    *fatkodima*

## Rails 7.0.2.4 (April 26, 2022) ##

*   No changes.


## Rails 7.0.2.3 (March 08, 2022) ##

*   No changes.


## Rails 7.0.2.2 (February 11, 2022) ##

*   No changes.


## Rails 7.0.2.1 (February 11, 2022) ##

*   No changes.


## Rails 7.0.2 (February 08, 2022) ##

*   Fix `PG.connect` keyword arguments deprecation warning on ruby 2.7.

    *Nikita Vasilevsky*

*   Fix the ability to exclude encryption params from being autofiltered.

    *Mark Gangl*

*   Dump the precision for datetime columns following the new defaults.

    *Rafael Mendonça França*

*   Make sure encrypted attributes are not being filtered twice.

    *Nikita Vasilevsky*

*   Dump the database schema containing the current Rails version.

    Since https://github.com/rails/rails/pull/42297, Rails now generate datetime columns
    with a default precision of 6. This means that users upgrading to Rails 7.0 from 6.1,
    when loading the database schema, would get the new precision value, which would not match
    the production schema.

    To avoid this the schema dumper will generate the new format which will include the Rails
    version and will look like this:

    ```
    ActiveRecord::Schema[7.0].define
    ```

    When upgrading from Rails 6.1 to Rails 7.0, you can run the `rails app:update` task that will
    set the current schema version to 6.1.

    *Rafael Mendonça França*

*   Fix parsing expression for PostgreSQL generated column.

    *fatkodima*

*   Fix `Mysql2::Error: Commands out of sync; you can't run this command now`
    when bulk-inserting fixtures that exceed `max_allowed_packet` configuration.

    *Nikita Vasilevsky*

*   Fix error when saving an association with a relation named `record`.

    *Dorian Marié*

*   Fix `MySQL::SchemaDumper` behavior about datetime precision value.

    *y0t4*

*   Improve associated with no reflection error.

    *Nikolai*

*   Fix PG.connect keyword arguments deprecation warning on ruby 2.7.

    Fixes #44307.

    *Nikita Vasilevsky*

*   Fix passing options to `check_constraint` from `change_table`.

    *Frederick Cheung*


## Rails 7.0.1 (January 06, 2022) ##


*   Change `QueryMethods#in_order_of` to drop records not listed in values.

    `in_order_of` now filters down to the values provided, to match the behavior of the `Enumerable` version.

    *Kevin Newton*

*   Allow named expression indexes to be revertible.

    Previously, the following code would raise an error in a reversible migration executed while rolling back, due to the index name not being used in the index removal.

    ```ruby
    add_index(:settings, "(data->'property')", using: :gin, name: :index_settings_data_property)
    ```

    Fixes #43331.

    *Oliver Günther*

*   Better error messages when association name is invalid in the argument of `ActiveRecord::QueryMethods::WhereChain#missing`.

    *ykpythemind*

*   Fix ordered migrations for single db in multi db environment.

    *Himanshu*

*   Extract `on update CURRENT_TIMESTAMP` for mysql2 adapter.

    *Kazuhiro Masuda*

*   Fix incorrect argument in PostgreSQL structure dump tasks.

    Updating the `--no-comment` argument added in Rails 7 to the correct `--no-comments` argument.

    *Alex Dent*

*   Fix schema dumping column default SQL values for sqlite3.

    *fatkodima*

*   Correctly parse complex check constraint expressions for PostgreSQL.

    *fatkodima*

*   Fix `timestamptz` attributes on PostgreSQL handle blank inputs.

    *Alex Ghiculescu*

*   Fix migration compatibility to create SQLite references/belongs_to column as integer when migration version is 6.0.

    Reference/belongs_to in migrations with version 6.0 were creating columns as
    bigint instead of integer for the SQLite Adapter.

    *Marcelo Lauxen*

*   Fix joining through a polymorphic association.

    *Alexandre Ruban*

*   Fix `QueryMethods#in_order_of` to handle empty order list.

    ```ruby
    Post.in_order_of(:id, []).to_a
    ```

    Also more explicitly set the column as secondary order, so that any other
    value is still ordered.

    *Jean Boussier*

*   Fix `rails dbconsole` for 3-tier config.

    *Eileen M. Uchitelle*

*   Fix quoting of column aliases generated by calculation methods.

    Since the alias is derived from the table name, we can't assume the result
    is a valid identifier.

    ```ruby
    class Test < ActiveRecord::Base
      self.table_name = '1abc'
    end
    Test.group(:id).count
    # syntax error at or near "1" (ActiveRecord::StatementInvalid)
    # LINE 1: SELECT COUNT(*) AS count_all, "1abc"."id" AS 1abc_id FROM "1...
    ```

    *Jean Boussier*


## Rails 7.0.0 (December 15, 2021) ##

*   Better handle SQL queries with invalid encoding.

    ```ruby
    Post.create(name: "broken \xC8 UTF-8")
    ```

    Would cause all adapters to fail in a non controlled way in the code
    responsible to detect write queries.

    The query is now properly passed to the database connection, which might or might
    not be able to handle it, but will either succeed or failed in a more correct way.

    *Jean Boussier*

*   Move database and shard selection config options to a generator.

    Rather than generating the config options in `production.rb` when applications are created, applications can now run a generator to create an initializer and uncomment / update options as needed. All multi-db configuration can be implemented in this initializer.

    *Eileen M. Uchitelle*


## Rails 7.0.0.rc3 (December 14, 2021) ##

*   No changes.


## Rails 7.0.0.rc2 (December 14, 2021) ##

*   No changes.


## Rails 7.0.0.rc1 (December 06, 2021) ##

*   Remove deprecated `ActiveRecord::DatabaseConfigurations::DatabaseConfig#spec_name`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Connection#in_clause_length`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Connection#allowed_index_name_length`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Base#remove_connection`.

    *Rafael Mendonça França*

*   Load STI Models in fixtures

    Data from Fixtures now loads based on the specific class for models with
    Single Table Inheritance. This affects enums defined in subclasses, previously
    the value of these fields was not parsed and remained `nil`

    *Andres Howard*

*   `#authenticate` returns false when the password is blank instead of raising an error.

    *Muhammad Muhammad Ibrahim*

*   Fix `ActiveRecord::QueryMethods#in_order_of` behavior for integer enums.

    `ActiveRecord::QueryMethods#in_order_of` didn't work as expected for enums stored as integers in the database when passing an array of strings or symbols as the order argument. This unexpected behavior occurred because the string or symbol values were not casted to match the integers in the database.

    The following example now works as expected:

    ```ruby
    class Book < ApplicationRecord
      enum status: [:proposed, :written, :published]
    end

    Book.in_order_of(:status, %w[written published proposed])
    ```

    *Alexandre Ruban*

*   Ignore persisted in-memory records when merging target lists.

    *Kevin Sjöberg*

*   Add a new option `:update_only` to `upsert_all` to configure the list of columns to update in case of conflict.

    Before, you could only customize the update SQL sentence via `:on_duplicate`. There is now a new option `:update_only` that lets you provide a list of columns to update in case of conflict:

    ```ruby
    Commodity.upsert_all(
      [
        { id: 2, name: "Copper", price: 4.84 },
        { id: 4, name: "Gold", price: 1380.87 },
        { id: 6, name: "Aluminium", price: 0.35 }
      ],
      update_only: [:price] # Only prices will be updated
    )
    ```

    *Jorge Manrubia*

*   Remove deprecated `ActiveRecord::Result#map!` and `ActiveRecord::Result#collect!`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Base.configurations.to_h`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Base.configurations.default_hash`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Base.arel_attribute`.

    *Rafael Mendonça França*

*   Remove deprecated `ActiveRecord::Base.connection_config`.

    *Rafael Mendonça França*

*   Filter attributes in SQL logs

    Previously, SQL queries in logs containing `ActiveRecord::Base.filter_attributes` were not filtered.

    Now, the filter attributes will be masked `[FILTERED]` in the logs when `prepared_statement` is enabled.

    ```
    # Before:
      Foo Load (0.2ms)  SELECT "foos".* FROM "foos" WHERE "foos"."passw" = ? LIMIT ?  [["passw", "hello"], ["LIMIT", 1]]

    # After:
      Foo Load (0.5ms)  SELECT "foos".* FROM "foos" WHERE "foos"."passw" = ? LIMIT ?  [["passw", "[FILTERED]"], ["LIMIT", 1]]
    ```

    *Aishwarya Subramanian*

*   Remove deprecated `Tasks::DatabaseTasks.spec`.

    *Rafael Mendonça França*

*   Remove deprecated `Tasks::DatabaseTasks.current_config`.

    *Rafael Mendonça França*

*   Deprecate `Tasks::DatabaseTasks.schema_file_type`.

    *Rafael Mendonça França*

*   Remove deprecated `Tasks::DatabaseTasks.dump_filename`.

    *Rafael Mendonça França*

*   Remove deprecated `Tasks::DatabaseTasks.schema_file`.

    *Rafael Mendonça França*

*   Remove deprecated `environment` and `name` arguments from `Tasks::DatabaseTasks.schema_up_to_date?`.

    *Rafael Mendonça França*

*   Merging conditions on the same column no longer maintain both conditions,
    and will be consistently replaced by the latter condition.

    ```ruby
    # Rails 6.1 (IN clause is replaced by merger side equality condition)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    # Rails 6.1 (both conflict conditions exists, deprecated)
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => []
    # Rails 6.1 with rewhere to migrate to Rails 7.0's behavior
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob), rewhere: true) # => [bob]
    # Rails 7.0 (same behavior with IN clause, mergee side condition is consistently replaced)
    Author.where(id: [david.id, mary.id]).merge(Author.where(id: bob)) # => [bob]
    Author.where(id: david.id..mary.id).merge(Author.where(id: bob)) # => [bob]

    *Rafael Mendonça França*

*   Remove deprecated support to `Model.reorder(nil).first` to search using non-deterministic order.

    *Rafael Mendonça França*

*   Remove deprecated rake tasks:

    * `db:schema:load_if_ruby`
    * `db:structure:dump`
    * `db:structure:load`
    * `db:structure:load_if_sql`
    * `db:structure:dump:#{name}`
    * `db:structure:load:#{name}`
    * `db:test:load_structure`
    * `db:test:load_structure:#{name}`

    *Rafael Mendonça França*

*   Remove deprecated `DatabaseConfig#config` method.

    *Rafael Mendonça França*

*   Rollback transactions when the block returns earlier than expected.

    Before this change, when a transaction block returned early, the transaction would be committed.

    The problem is that timeouts triggered inside the transaction block was also making the incomplete transaction
    to be committed, so in order to avoid this mistake, the transaction block is rolled back.

    *Rafael Mendonça França*

*   Add middleware for automatic shard swapping.

    Provides a basic middleware to perform automatic shard swapping. Applications will provide a resolver which will determine for an individual request which shard should be used. Example:

    ```ruby
    config.active_record.shard_resolver = ->(request) {
      subdomain = request.subdomain
      tenant = Tenant.find_by_subdomain!(subdomain)
      tenant.shard
    }
    ```

    See guides for more details.

    *Eileen M. Uchitelle*, *John Crepezzi*

*   Remove deprecated support to pass a column to `type_cast`.

    *Rafael Mendonça França*

*   Remove deprecated support to type cast to database values `ActiveRecord::Base` objects.

    *Rafael Mendonça França*

*   Remove deprecated support to quote `ActiveRecord::Base` objects.

    *Rafael Mendonça França*

*   Remove deprecacated support to resolve connection using `"primary"` as connection specification name.

    *Rafael Mendonça França*

*   Remove deprecation warning when using `:interval` column is used in PostgreSQL database.

    Now, interval columns will return `ActiveSupport::Duration` objects instead of strings.

    To keep the old behavior, you can add this line to your model:

    ```ruby
    attribute :column, :string
    ```

    *Rafael Mendonça França*

*   Remove deprecated support to YAML load `ActiveRecord::Base` instance in the Rails 4.2 and 4.1 formats.

    *Rafael Mendonça França*

*   Remove deprecated option `:spec_name` in the `configs_for` method.

    *Rafael Mendonça França*

*   Remove deprecated  `ActiveRecord::Base.allow_unsafe_raw_sql`.

    *Rafael Mendonça França*

*   Fix regression bug that caused ignoring additional conditions for preloading has_many-through relations.

    Fixes #43132

    *Alexander Pauly*

*   Fix `has_many` inversing recursion on models with recursive associations.

    *Gannon McGibbon*

*   Add `accepts_nested_attributes_for` support for `delegated_type`

    ```ruby
    class Entry < ApplicationRecord
      delegated_type :entryable, types: %w[ Message Comment ]
      accepts_nested_attributes_for :entryable
    end

    entry = Entry.create(entryable_type: 'Message', entryable_attributes: { content: 'Hello world' })
    # => #<Entry:0x00>
    # id: 1
    # entryable_id: 1,
    # entryable_type: 'Message'
    # ...>

    entry.entryable
    # => #<Message:0x01>
    # id: 1
    # content: 'Hello world'
    # ...>
    ```

    Previously it would raise an error:

    ```ruby
    Entry.create(entryable_type: 'Message', entryable_attributes: { content: 'Hello world' })
    # ArgumentError: Cannot build association `entryable'. Are you trying to build a polymorphic one-to-one association?
    ```

    *Sjors Baltus*

*   Use subquery for DELETE with GROUP_BY and HAVING clauses.

    Prior to this change, deletes with GROUP_BY and HAVING were returning an error.

    After this change, GROUP_BY and HAVING are valid clauses in DELETE queries, generating the following query:

    ```sql
    DELETE FROM "posts" WHERE "posts"."id" IN (
        SELECT "posts"."id" FROM "posts" INNER JOIN "comments" ON "comments"."post_id" = "posts"."id" GROUP BY "posts"."id" HAVING (count(comments.id) >= 2))
    )  [["flagged", "t"]]
    ```

    *Ignacio Chiazzo Cardarello*

*   Use subquery for UPDATE with GROUP_BY and HAVING clauses.

    Prior to this change, updates with GROUP_BY and HAVING were being ignored, generating a SQL like this:

    ```sql
    UPDATE "posts" SET "flagged" = ? WHERE "posts"."id" IN (
        SELECT "posts"."id" FROM "posts" INNER JOIN "comments" ON "comments"."post_id" = "posts"."id"
    )  [["flagged", "t"]]
    ```

    After this change, GROUP_BY and HAVING clauses are used as a subquery in updates, like this:

    ```sql
    UPDATE "posts" SET "flagged" = ? WHERE "posts"."id" IN (
        SELECT "posts"."id" FROM "posts" INNER JOIN "comments" ON "comments"."post_id" = "posts"."id"
        GROUP BY posts.id HAVING (count(comments.id) >= 2)
    )  [["flagged", "t"]]
    ```

    *Ignacio Chiazzo Cardarello*

*   Add support for setting the filename of the schema or structure dump in the database config.

    Applications may now set their the filename or path of the schema / structure dump file in their database configuration.

    ```yaml
    production:
      primary:
        database: my_db
        schema_dump: my_schema_dump_filename.rb
      animals:
        database: animals_db
        schema_dump: false
    ```

    The filename set in `schema_dump` will be used by the application. If set to `false` the schema will not be dumped. The database tasks are responsible for adding the database directory to the filename. If a full path is provided, the Rails tasks will use that instead of `ActiveRecord::DatabaseTasks.db_dir`.

    *Eileen M. Uchitelle*, *Ryan Kerr*

*   Add `ActiveRecord::Base.prohibit_shard_swapping` to prevent attempts to change the shard within a block.

    *John Crepezzi*, *Eileen M. Uchitelle*

*   Filter unchanged attributes with default function from insert query when `partial_inserts` is disabled.

    *Akshay Birajdar*, *Jacopo Beschi*

*   Add support for FILTER clause (SQL:2003) to Arel.

    Currently supported by PostgreSQL 9.4+ and SQLite 3.30+.

    *Andrey Novikov*

*   Automatically set timestamps on record creation during bulk insert/upsert

    Prior to this change, only updates during an upsert operation (e.g. `upsert_all`) would touch timestamps (`updated_{at,on}`). Now, record creations also touch timestamp columns (`{created,updated}_{at,on}`).

    This behaviour is controlled by the `<model>.record_timestamps` config, matching the behaviour of `create`, `update`, etc. It can also be overridden by using the `record_timestamps:` keyword argument.

    Note that this means `upsert_all` on models with `record_timestamps = false` will no longer touch `updated_{at,on}` automatically.

    *Sam Bostock*

*   Don't require `role` when passing `shard` to `connected_to`.

    `connected_to` can now be called with a `shard` only. Note that `role` is still inherited if `connected_to` calls are nested.

    *Eileen M. Uchitelle*

*   Add option to lazily load the schema cache on the connection.

    Previously, the only way to load the schema cache in Active Record was through the Railtie on boot. This option provides the ability to load the schema cache on the connection after it's been established. Loading the cache lazily on the connection can be beneficial for Rails applications that use multiple databases because it will load the cache at the time the connection is established. Currently Railties doesn't have access to the connections before boot.

    To use the cache, set `config.active_record.lazily_load_schema_cache = true` in your application configuration. In addition a `schema_cache_path` should be set in your database configuration if you don't want to use the default "db/schema_cache.yml" path.

    *Eileen M. Uchitelle*

*   Allow automatic `inverse_of` detection for associations with scopes.

    Automatic `inverse_of` detection now works for associations with scopes. For
    example, the `comments` association here now automatically detects
    `inverse_of: :post`, so we don't need to pass that option:

    ```ruby
    class Post < ActiveRecord::Base
      has_many :comments, -> { visible }
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end
    ```

    Note that the automatic detection still won't work if the inverse
    association has a scope. In this example a scope on the `post` association
    would still prevent Rails from finding the inverse for the `comments`
    association.

    This will be the default for new apps in Rails 7. To opt in:

    ```ruby
    config.active_record.automatic_scope_inversing = true
    ```

    *Daniel Colson*, *Chris Bloom*

*   Accept optional transaction args to `ActiveRecord::Locking::Pessimistic#with_lock`

    `#with_lock` now accepts transaction options like `requires_new:`,
    `isolation:`, and `joinable:`

    *John Mileham*

*   Adds support for deferrable foreign key constraints in PostgreSQL.

    By default, foreign key constraints in PostgreSQL are checked after each statement. This works for most use cases,
    but becomes a major limitation when creating related records before the parent record is inserted into the database.
    One example of this is looking up / creating a person via one or more unique alias.

    ```ruby
    Person.transaction do
      alias = Alias
        .create_with(user_id: SecureRandom.uuid)
        .create_or_find_by(name: "DHH")

      person = Person
        .create_with(name: "David Heinemeier Hansson")
        .create_or_find_by(id: alias.user_id)
    end
    ```

    Using the default behavior, the transaction would fail when executing the first `INSERT` statement.

    By passing the `:deferrable` option to the `add_foreign_key` statement in migrations, it's possible to defer this
    check.

    ```ruby
    add_foreign_key :aliases, :person, deferrable: true
    ```

    Passing `deferrable: true` doesn't change the default behavior, but allows manually deferring the check using
    `SET CONSTRAINTS ALL DEFERRED` within a transaction. This will cause the foreign keys to be checked after the
    transaction.

    It's also possible to adjust the default behavior from an immediate check (after the statement), to a deferred check
    (after the transaction):

    ```ruby
    add_foreign_key :aliases, :person, deferrable: :deferred
    ```

    *Benedikt Deicke*

*   Allow configuring Postgres password through the socket URL.

    For example:
    ```ruby
    ActiveRecord::DatabaseConfigurations::UrlConfig.new(
      :production, :production, 'postgres:///?user=user&password=secret&dbname=app', {}
    ).configuration_hash
    ```

    will now return,

    ```ruby
    { :user=>"user", :password=>"secret", :dbname=>"app", :adapter=>"postgresql" }
    ```

    *Abeid Ahmed*

*   PostgreSQL: support custom enum types

    In migrations, use `create_enum` to add a new enum type, and `t.enum` to add a column.

    ```ruby
    def up
      create_enum :mood, ["happy", "sad"]

      change_table :cats do |t|
        t.enum :current_mood, enum_type: "mood", default: "happy", null: false
      end
    end
    ```

    Enums will be presented correctly in `schema.rb`. Note that this is only supported by
    the PostgreSQL adapter.

    *Alex Ghiculescu*

*   Avoid COMMENT statements in PostgreSQL structure dumps

    COMMENT statements are now omitted from the output of `db:structure:dump` when using PostgreSQL >= 11.
    This allows loading the dump without a pgsql superuser account.

    Fixes #36816, #43107.

    *Janosch Müller*

*   Add support for generated columns in PostgreSQL adapter

    Generated columns are supported since version 12.0 of PostgreSQL. This adds
    support of those to the PostgreSQL adapter.

    ```ruby
    create_table :users do |t|
      t.string :name
      t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
    end
    ```

    *Michał Begejowicz*


## Rails 7.0.0.alpha2 (September 15, 2021) ##

*   No changes.


## Rails 7.0.0.alpha1 (September 15, 2021) ##

*   Remove warning when overwriting existing scopes

    Removes the following unnecessary warning message that appeared when overwriting existing scopes

    ```
    Creating scope :my_scope_name. Overwriting existing method "MyClass.my_scope_name" when overwriting existing scopes
    ```

     *Weston Ganger*

*   Use full precision for `updated_at` in `insert_all`/`upsert_all`

    `CURRENT_TIMESTAMP` provides differing precision depending on the database,
    and not all databases support explicitly specifying additional precision.

    Instead, we delegate to the new `connection.high_precision_current_timestamp`
    for the SQL to produce a high precision timestamp on the current database.

    Fixes #42992

    *Sam Bostock*

*   Add ssl support for postgresql database tasks

    Add `PGSSLMODE`, `PGSSLCERT`, `PGSSLKEY` and `PGSSLROOTCERT` to pg_env from database config
    when running postgresql database tasks.

    ```yaml
    # config/database.yml

    production:
      sslmode: verify-full
      sslcert: client.crt
      sslkey: client.key
      sslrootcert: ca.crt
    ```

    Environment variables

    ```
    PGSSLMODE=verify-full
    PGSSLCERT=client.crt
    PGSSLKEY=client.key
    PGSSLROOTCERT=ca.crt
    ```

    Fixes #42994

    *Michael Bayucot*

*   Avoid scoping update callbacks in `ActiveRecord::Relation#update!`.

    Making it consistent with how scoping is applied only to the query in `ActiveRecord::Relation#update`
    and not also to the callbacks from the update itself.

    *Dylan Thacker-Smith*

*   Fix 2 cases that inferred polymorphic class from the association's `foreign_type`
    using `String#constantize` instead of the model's `polymorphic_class_for`.

    When updating a polymorphic association, the old `foreign_type` was not inferred correctly when:
    1. `touch`ing the previously associated record
    2. updating the previously associated record's `counter_cache`

    *Jimmy Bourassa*

*   Add config option for ignoring tables when dumping the schema cache.

    Applications can now be configured to ignore certain tables when dumping the schema cache.

    The configuration option can table an array of tables:

    ```ruby
    config.active_record.schema_cache_ignored_tables = ["ignored_table", "another_ignored_table"]
    ```

    Or a regex:

    ```ruby
    config.active_record.schema_cache_ignored_tables = [/^_/]
    ```

    *Eileen M. Uchitelle*

*   Make schema cache methods return consistent results.

    Previously the schema cache methods `primary_keys`, `columns`, `columns_hash`, and `indexes`
    would behave differently than one another when a table didn't exist and differently across
    database adapters. This change unifies the behavior so each method behaves the same regardless
    of adapter.

    The behavior now is:

    `columns`: (unchanged) raises a db error if the table does not exist.
    `columns_hash`: (unchanged) raises a db error if the table does not exist.
    `primary_keys`: (unchanged) returns `nil` if the table does not exist.
    `indexes`: (changed for mysql2) returns `[]` if the table does not exist.

    *Eileen M. Uchitelle*

*   Reestablish connection to previous database after after running `db:schema:load:name`

    After running `db:schema:load:name` the previous connection is restored.

    *Jacopo Beschi*

*   Add database config option `database_tasks`

    If you would like to connect to an external database without any database
    management tasks such as schema management, migrations, seeds, etc. you can set
    the per database config option `database_tasks: false`

    ```yaml
    # config/database.yml

    production:
      primary:
        database: my_database
        adapter: mysql2
      animals:
        database: my_animals_database
        adapter: mysql2
        database_tasks: false
    ```

    *Weston Ganger*

*   Fix `ActiveRecord::InternalMetadata` to not be broken by `config.active_record.record_timestamps = false`

    Since the model always create the timestamp columns, it has to set them, otherwise it breaks
    various DB management tasks.

    Fixes #42983

*   Add `ActiveRecord::QueryLogs`.

    Configurable tags can be automatically added to all SQL queries generated by Active Record.

    ```ruby
    # config/application.rb
    module MyApp
      class Application < Rails::Application
        config.active_record.query_log_tags_enabled = true
      end
    end
    ```

    By default the application, controller and action details are added to the query tags:

    ```ruby
    class BooksController < ApplicationController
      def index
        @books = Book.all
      end
    end
    ```

    ```ruby
    GET /books
    # SELECT * FROM books /*application:MyApp;controller:books;action:index*/
    ```

    Custom tags containing static values and Procs can be defined in the application configuration:

    ```ruby
    config.active_record.query_log_tags = [
      :application,
      :controller,
      :action,
      {
        custom_static: "foo",
        custom_dynamic: -> { Time.now }
      }
    ]
    ```

    *Keeran Raj Hawoldar*, *Eileen M. Uchitelle*, *Kasper Timm Hansen*

*   Added support for multiple databases to `rails db:setup` and `rails db:reset`.

    *Ryan Hall*

*   Add `ActiveRecord::Relation#structurally_compatible?`.

    Adds a query method by which a user can tell if the relation that they're
    about to use for `#or` or `#and` is structurally compatible with the
    receiver.

    *Kevin Newton*

*   Add `ActiveRecord::QueryMethods#in_order_of`.

    This allows you to specify an explicit order that you'd like records
    returned in based on a SQL expression. By default, this will be accomplished
    using a case statement, as in:

    ```ruby
    Post.in_order_of(:id, [3, 5, 1])
    ```

    will generate the SQL:

    ```sql
    SELECT "posts".* FROM "posts" ORDER BY CASE "posts"."id" WHEN 3 THEN 1 WHEN 5 THEN 2 WHEN 1 THEN 3 ELSE 4 END ASC
    ```

    However, because this functionality is built into MySQL in the form of the
    `FIELD` function, that connection adapter will generate the following SQL
    instead:

    ```sql
    SELECT "posts".* FROM "posts" ORDER BY FIELD("posts"."id", 1, 5, 3) DESC
    ```

    *Kevin Newton*

*   Fix `eager_loading?` when ordering with `Symbol`.

    `eager_loading?` is triggered correctly when using `order` with symbols.

    ```ruby
    scope = Post.includes(:comments).order(:"comments.label")
    => true
    ```

    *Jacopo Beschi*

*   Two change tracking methods are added for `belongs_to` associations.

    The `association_changed?` method (assuming an association named `:association`) returns true
    if a different associated object has been assigned and the foreign key will be updated in the
    next save.

    The `association_previously_changed?` method returns true if the previous save updated the
    association to reference a different associated object.

    *George Claghorn*

*   Add option to disable schema dump per-database.

    Dumping the schema is on by default for all databases in an application. To turn it off for a
    specific database, use the `schema_dump` option:

    ```yaml
    # config/database.yml

    production:
      schema_dump: false
    ```

    *Luis Vasconcellos*, *Eileen M. Uchitelle*

*   Fix `eager_loading?` when ordering with `Hash` syntax.

    `eager_loading?` is triggered correctly when using `order` with hash syntax
    on an outer table.

    ```ruby
    Post.includes(:comments).order({ "comments.label": :ASC }).eager_loading?
    # => true
    ```

    *Jacopo Beschi*

*   Move the forcing of clear text encoding to the `ActiveRecord::Encryption::Encryptor`.

    Fixes #42699.

    *J Smith*

*   `partial_inserts` is now disabled by default in new apps.

    This will be the default for new apps in Rails 7. To opt in:

    ```ruby
    config.active_record.partial_inserts = true
    ```

    If a migration removes the default value of a column, this option
    would cause old processes to no longer be able to create new records.

    If you need to remove a column, you should first use `ignored_columns`
    to stop using it.

    *Jean Boussier*

*   Rails can now verify foreign keys after loading fixtures in tests.

    This will be the default for new apps in Rails 7. To opt in:

    ```ruby
    config.active_record.verify_foreign_keys_for_fixtures = true
    ```

    Tests will not run if there is a foreign key constraint violation in your fixture data.

    The feature is supported by SQLite and PostgreSQL, other adapters can also add support for it.

    *Alex Ghiculescu*

*   Clear cached `has_one` association after setting `belongs_to` association to `nil`.

    After setting a `belongs_to` relation to `nil` and updating an unrelated attribute on the owner,
    the owner should still return `nil` on the `has_one` relation.

    Fixes #42597.

    *Michiel de Mare*

*   OpenSSL constants are now used for Digest computations.

    *Dirkjan Bussink*

*   Adds support for `if_not_exists` to `add_foreign_key` and `if_exists` to `remove_foreign_key`.

    Applications can set their migrations to ignore exceptions raised when adding a foreign key
    that already exists or when removing a foreign key that does not exist.

    Example Usage:

    ```ruby
    class AddAuthorsForeignKeyToArticles < ActiveRecord::Migration[7.0]
      def change
        add_foreign_key :articles, :authors, if_not_exists: true
      end
    end
    ```

    ```ruby
    class RemoveAuthorsForeignKeyFromArticles < ActiveRecord::Migration[7.0]
      def change
        remove_foreign_key :articles, :authors, if_exists: true
      end
    end
    ```

    *Roberto Miranda*

*   Prevent polluting ENV during postgresql structure dump/load.

    Some configuration parameters were provided to pg_dump / psql via
    environment variables which persisted beyond the command being run, and may
    have caused subsequent commands and connections to fail. Tasks running
    across multiple postgresql databases like `rails db:test:prepare` may have
    been affected.

    *Samuel Cochran*

*   Set precision 6 by default for `datetime` columns.

    By default, datetime columns will have microseconds precision instead of seconds precision.

    *Roberto Miranda*

*   Allow preloading of associations with instance dependent scopes.

    *John Hawthorn*, *John Crepezzi*, *Adam Hess*, *Eileen M. Uchitelle*, *Dinah Shi*

*   Do not try to rollback transactions that failed due to a `ActiveRecord::TransactionRollbackError`.

    *Jamie McCarthy*

*   Active Record Encryption will now encode values as UTF-8 when using deterministic
    encryption. The encoding is part of the encrypted payload, so different encodings for
    different values result in different ciphertexts. This can break unique constraints and
    queries.

    The new behavior is configurable via `active_record.encryption.forced_encoding_for_deterministic_encryption`
    that is `Encoding::UTF_8` by default. It can be disabled by setting it to `nil`.

    *Jorge Manrubia*

*   The MySQL adapter now cast numbers and booleans bind parameters to string for safety reasons.

    When comparing a string and a number in a query, MySQL converts the string to a number. So for
    instance `"foo" = 0`, will implicitly cast `"foo"` to `0` and will evaluate to `TRUE` which can
    lead to security vulnerabilities.

    Active Record already protect against that vulnerability when it knows the type of the column
    being compared, however until now it was still vulnerable when using bind parameters:

    ```ruby
    User.where("login_token = ?", 0).first
    ```

    Would perform:

    ```sql
    SELECT * FROM `users` WHERE `login_token` = 0 LIMIT 1;
    ```

    Now it will perform:

    ```sql
    SELECT * FROM `users` WHERE `login_token` = '0' LIMIT 1;
    ```

    *Jean Boussier*

*   Fixture configurations (`_fixture`) are now strictly validated.

    If an error will be raised if that entry contains unknown keys while previously it
    would silently have no effects.

    *Jean Boussier*

*   Add `ActiveRecord::Base.update!` that works like `ActiveRecord::Base.update` but raises exceptions.

    This allows for the same behavior as the instance method `#update!` at a class level.

    ```ruby
    Person.update!(:all, state: "confirmed")
    ```

    *Dorian Marié*

*   Add `ActiveRecord::Base#attributes_for_database`.

    Returns attributes with values for assignment to the database.

    *Chris Salzberg*

*   Use an empty query to check if the PostgreSQL connection is still active.

    An empty query is faster than `SELECT 1`.

    *Heinrich Lee Yu*

*   Add `ActiveRecord::Base#previously_persisted?`.

    Returns `true` if the object has been previously persisted but now it has been deleted.

*   Deprecate `partial_writes` in favor of `partial_inserts` and `partial_updates`.

    This allows to have a different behavior on update and create.

    *Jean Boussier*

*   Fix compatibility with `psych >= 4`.

    Starting in Psych 4.0.0 `YAML.load` behaves like `YAML.safe_load`. To preserve compatibility,
    Active Record's schema cache loader and `YAMLColumn` now uses `YAML.unsafe_load` if available.

    *Jean Boussier*

*   `ActiveRecord::Base.logger` is now a `class_attribute`.

    This means it can no longer be accessed directly through `@@logger`, and that setting `logger =`
    on a subclass won't change the parent's logger.

    *Jean Boussier*

*   Add `.asc.nulls_first` for all databases. Unfortunately MySQL still doesn't like `nulls_last`.

    *Keenan Brock*

*   Improve performance of `one?` and `many?` by limiting the generated count query to 2 results.

    *Gonzalo Riestra*

*   Don't check type when using `if_not_exists` on `add_column`.

    Previously, if a migration called `add_column` with the `if_not_exists` option set to true
    the `column_exists?` check would look for a column with the same name and type as the migration.

    Recently it was discovered that the type passed to the migration is not always the same type
    as the column after migration. For example a column set to `:mediumblob` in the migration will
    be casted to `binary` when calling `column.type`. Since there is no straightforward way to cast
    the type to the database type without running the migration, we opted to drop the type check from
    `add_column`. This means that migrations adding a duplicate column with a different type will no
    longer raise an error.

    *Eileen M. Uchitelle*

*   Log a warning message when running SQLite in production.

    Using SQLite in production ENV is generally discouraged. SQLite is also the default adapter
    in a new Rails application.
    For the above reasons log a warning message when running SQLite in production.

    The warning can be disabled by setting `config.active_record.sqlite3_production_warning=false`.

    *Jacopo Beschi*

*   Add option to disable joins for `has_one` associations.

    In a multiple database application, associations can't join across
    databases. When set, this option instructs Rails to generate 2 or
    more queries rather than generating joins for `has_one` associations.

    Set the option on a has one through association:

    ```ruby
    class Person
      has_one :dog
      has_one :veterinarian, through: :dog, disable_joins: true
    end
    ```

    Then instead of generating join SQL, two queries are used for `@person.veterinarian`:

    ```
    SELECT "dogs"."id" FROM "dogs" WHERE "dogs"."person_id" = ?  [["person_id", 1]]
    SELECT "veterinarians".* FROM "veterinarians" WHERE "veterinarians"."dog_id" = ?  [["dog_id", 1]]
    ```

    *Sarah Vessels*, *Eileen M. Uchitelle*

*   `Arel::Visitors::Dot` now renders a complete set of properties when visiting
    `Arel::Nodes::SelectCore`, `SelectStatement`, `InsertStatement`, `UpdateStatement`, and
    `DeleteStatement`, which fixes #42026. Previously, some properties were omitted.

    *Mike Dalessio*

*   `Arel::Visitors::Dot` now supports `Arel::Nodes::Bin`, `Case`, `CurrentRow`, `Distinct`,
    `DistinctOn`, `Else`, `Except`, `InfixOperation`, `Intersect`, `Lock`, `NotRegexp`, `Quoted`,
    `Regexp`, `UnaryOperation`, `Union`, `UnionAll`, `When`, and `With`. Previously, these node
    types caused an exception to be raised by `Arel::Visitors::Dot#accept`.

    *Mike Dalessio*

*   Optimize `remove_columns` to use a single SQL statement.

    ```ruby
    remove_columns :my_table, :col_one, :col_two
    ```

    Now results in the following SQL:

    ```sql
    ALTER TABLE "my_table" DROP COLUMN "col_one", DROP COLUMN "col_two"
    ```

    *Jon Dufresne*

*   Ensure `has_one` autosave association callbacks get called once.

    Change the `has_one` autosave callback to be non cyclic as well.
    By doing this the autosave callback are made more consistent for
    all 3 cases: `has_many`, `has_one`, and `belongs_to`.

    *Petrik de Heus*

*   Add option to disable joins for associations.

    In a multiple database application, associations can't join across
    databases. When set, this option instructs Rails to generate 2 or
    more queries rather than generating joins for associations.

    Set the option on a has many through association:

    ```ruby
    class Dog
      has_many :treats, through: :humans, disable_joins: true
      has_many :humans
    end
    ```

    Then instead of generating join SQL, two queries are used for `@dog.treats`:

    ```
    SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
    SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
    ```

    *Eileen M. Uchitelle*, *Aaron Patterson*, *Lee Quarella*

*   Add setting for enumerating column names in SELECT statements.

    Adding a column to a PostgreSQL database, for example, while the application is running can
    change the result of wildcard `SELECT *` queries, which invalidates the result
    of cached prepared statements and raises a `PreparedStatementCacheExpired` error.

    When enabled, Active Record will avoid wildcards and always include column names
    in `SELECT` queries, which will return consistent results and avoid prepared
    statement errors.

    Before:

    ```ruby
    Book.limit(5)
    # SELECT * FROM books LIMIT 5
    ```

    After:

    ```ruby
    # config/application.rb
    module MyApp
      class Application < Rails::Application
        config.active_record.enumerate_columns_in_select_statements = true
      end
    end

    # or, configure per-model
    class Book < ApplicationRecord
      self.enumerate_columns_in_select_statements = true
    end
    ```

    ```ruby
    Book.limit(5)
    # SELECT id, author_id, name, format, status, language, etc FROM books LIMIT 5
    ```

    *Matt Duszynski*

*   Allow passing SQL as `on_duplicate` value to `#upsert_all` to make it possible to use raw SQL to update columns on conflict:

    ```ruby
    Book.upsert_all(
      [{ id: 1, status: 1 }, { id: 2, status: 1 }],
      on_duplicate: Arel.sql("status = GREATEST(books.status, EXCLUDED.status)")
    )
    ```

    *Vladimir Dementyev*

*   Allow passing SQL as `returning` statement to `#upsert_all`:

    ```ruby
    Article.insert_all(
      [
        { title: "Article 1", slug: "article-1", published: false },
        { title: "Article 2", slug: "article-2", published: false }
      ],
      returning: Arel.sql("id, (xmax = '0') as inserted, name as new_name")
    )
    ```

    *Vladimir Dementyev*

*   Deprecate `legacy_connection_handling`.

    *Eileen M. Uchitelle*

*   Add attribute encryption support.

    Encrypted attributes are declared at the model level. These
    are regular Active Record attributes backed by a column with
    the same name. The system will transparently encrypt these
    attributes before saving them into the database and will
    decrypt them when retrieving their values.


    ```ruby
    class Person < ApplicationRecord
      encrypts :name
      encrypts :email_address, deterministic: true
    end
    ```

    You can learn more in the [Active Record Encryption
    guide](https://edgeguides.rubyonrails.org/active_record_encryption.html).

    *Jorge Manrubia*

*   Changed Arel predications `contains` and `overlaps` to use
    `quoted_node` so that PostgreSQL arrays are quoted properly.

    *Bradley Priest*

*   Add mode argument to record level `strict_loading!`.

    This argument can be used when enabling strict loading for a single record
    to specify that we only want to raise on n plus one queries.

    ```ruby
    developer.strict_loading!(mode: :n_plus_one_only)

    developer.projects.to_a # Does not raise
    developer.projects.first.client # Raises StrictLoadingViolationError
    ```

    Previously, enabling strict loading would cause any lazily loaded
    association to raise an error. Using `n_plus_one_only` mode allows us to
    lazily load belongs_to, has_many, and other associations that are fetched
    through a single query.

    *Dinah Shi*

*   Fix Float::INFINITY assignment to datetime column with postgresql adapter.

    Before:

    ```ruby
    # With this config
    ActiveRecord::Base.time_zone_aware_attributes = true

    # and the following schema:
    create_table "postgresql_infinities" do |t|
      t.datetime "datetime"
    end

    # This test fails
    record = PostgresqlInfinity.create!(datetime: Float::INFINITY)
    assert_equal Float::INFINITY, record.datetime # record.datetime gets nil
    ```

    After this commit, `record.datetime` gets `Float::INFINITY` as expected.

    *Shunichi Ikegami*

*   Type cast enum values by the original attribute type.

    The notable thing about this change is that unknown labels will no longer match 0 on MySQL.

    ```ruby
    class Book < ActiveRecord::Base
      enum :status, { proposed: 0, written: 1, published: 2 }
    end
    ```

    Before:

    ```ruby
    # SELECT `books`.* FROM `books` WHERE `books`.`status` = 'prohibited' LIMIT 1
    Book.find_by(status: :prohibited)
    # => #<Book id: 1, status: "proposed", ...> (for mysql2 adapter)
    # => ActiveRecord::StatementInvalid: PG::InvalidTextRepresentation: ERROR:  invalid input syntax for type integer: "prohibited" (for postgresql adapter)
    # => nil (for sqlite3 adapter)
    ```

    After:

    ```ruby
    # SELECT `books`.* FROM `books` WHERE `books`.`status` IS NULL LIMIT 1
    Book.find_by(status: :prohibited)
    # => nil (for all adapters)
    ```

    *Ryuta Kamizono*

*   Fixtures for `has_many :through` associations now load timestamps on join tables.

    Given this fixture:

    ```yml
    ### monkeys.yml
    george:
      name: George the Monkey
      fruits: apple

    ### fruits.yml
    apple:
      name: apple
    ```

    If the join table (`fruit_monkeys`) contains `created_at` or `updated_at` columns,
    these will now be populated when loading the fixture. Previously, fixture loading
    would crash if these columns were required, and leave them as null otherwise.

    *Alex Ghiculescu*

*   Allow applications to configure the thread pool for async queries.

    Some applications may want one thread pool per database whereas others want to use
    a single global thread pool for all queries. By default, Rails will set `async_query_executor`
    to `nil` which will not initialize any executor. If `load_async` is called and no executor
    has been configured, the query will be executed in the foreground.

    To create one thread pool for all database connections to use applications can set
    `config.active_record.async_query_executor` to `:global_thread_pool` and optionally define
    `config.active_record.global_executor_concurrency`. This defaults to 4. For applications that want
    to have a thread pool for each database connection, `config.active_record.async_query_executor` can
    be set to `:multi_thread_pool`. The configuration for each thread pool is set in the database
    configuration.

    *Eileen M. Uchitelle*

*   Allow new syntax for `enum` to avoid leading `_` from reserved options.

    Before:

    ```ruby
    class Book < ActiveRecord::Base
      enum status: [ :proposed, :written ], _prefix: true, _scopes: false
      enum cover: [ :hard, :soft ], _suffix: true, _default: :hard
    end
    ```

    After:

    ```ruby
    class Book < ActiveRecord::Base
      enum :status, [ :proposed, :written ], prefix: true, scopes: false
      enum :cover, [ :hard, :soft ], suffix: true, default: :hard
    end
    ```

    *Ryuta Kamizono*

*   Add `ActiveRecord::Relation#load_async`.

    This method schedules the query to be performed asynchronously from a thread pool.

    If the result is accessed before a background thread had the opportunity to perform
    the query, it will be performed in the foreground.

    This is useful for queries that can be performed long enough before their result will be
    needed, or for controllers which need to perform several independent queries.

    ```ruby
    def index
      @categories = Category.some_complex_scope.load_async
      @posts = Post.some_complex_scope.load_async
    end
    ```

    Active Record logs will also include timing info for the duration of how long
    the main thread had to wait to access the result. This timing is useful to know
    whether or not it's worth to load the query asynchronously.

    ```
    DEBUG -- :   Category Load (62.1ms)  SELECT * FROM `categories` LIMIT 50
    DEBUG -- :   ASYNC Post Load (64ms) (db time 126.1ms)  SELECT * FROM `posts` LIMIT 100
    ```

    The duration in the first set of parens is how long the main thread was blocked
    waiting for the results, and the second set of parens with "db time" is how long
    the entire query took to execute.

    *Jean Boussier*

*   Implemented `ActiveRecord::Relation#excluding` method.

    This method excludes the specified record (or collection of records) from
    the resulting relation:

    ```ruby
    Post.excluding(post)
    Post.excluding(post_one, post_two)
    ```

    Also works on associations:

    ```ruby
    post.comments.excluding(comment)
    post.comments.excluding(comment_one, comment_two)
    ```

    This is short-hand for `Post.where.not(id: post.id)` (for a single record)
    and `Post.where.not(id: [post_one.id, post_two.id])` (for a collection).

    *Glen Crawford*

*   Skip optimised #exist? query when #include? is called on a relation
    with a having clause.

    Relations that have aliased select values AND a having clause that
    references an aliased select value would generate an error when
    #include? was called, due to an optimisation that would generate
    call #exists? on the relation instead, which effectively alters
    the select values of the query (and thus removes the aliased select
    values), but leaves the having clause intact. Because the having
    clause is then referencing an aliased column that is no longer
    present in the simplified query, an ActiveRecord::InvalidStatement
    error was raised.

    A sample query affected by this problem:

    ```ruby
    Author.select('COUNT(*) as total_posts', 'authors.*')
          .joins(:posts)
          .group(:id)
          .having('total_posts > 2')
          .include?(Author.first)
    ```

    This change adds an addition check to the condition that skips the
    simplified #exists? query, which simply checks for the presence of
    a having clause.

    Fixes #41417.

    *Michael Smart*

*   Increment postgres prepared statement counter before making a prepared statement, so if the statement is aborted
    without Rails knowledge (e.g., if app gets killed during long-running query or due to Rack::Timeout), app won't end
    up in perpetual crash state for being inconsistent with PostgreSQL.

    *wbharding*, *Martin Tepper*

*   Add ability to apply `scoping` to `all_queries`.

    Some applications may want to use the `scoping` method but previously it only
    worked on certain types of queries. This change allows the `scoping` method to apply
    to all queries for a model in a block.

    ```ruby
    Post.where(blog_id: post.blog_id).scoping(all_queries: true) do
      post.update(title: "a post title") # adds `posts.blog_id = 1` to the query
    end
    ```

    *Eileen M. Uchitelle*

*   `ActiveRecord::Calculations.calculate` called with `:average`
    (aliased as `ActiveRecord::Calculations.average`) will now use column-based
    type casting. This means that floating-point number columns will now be
    aggregated as `Float` and decimal columns will be aggregated as `BigDecimal`.

    Integers are handled as a special case returning `BigDecimal` always
    (this was the case before already).

    ```ruby
    # With the following schema:
    create_table "measurements" do |t|
      t.float "temperature"
    end

    # Before:
    Measurement.average(:temperature).class
    # => BigDecimal

    # After:
    Measurement.average(:temperature).class
    # => Float
    ```

    Before this change, Rails just called `to_d` on average aggregates from the
    database adapter. This is not the case anymore. If you relied on that kind
    of magic, you now need to register your own `ActiveRecord::Type`
    (see `ActiveRecord::Attributes::ClassMethods` for documentation).

    *Josua Schmid*

*   PostgreSQL: introduce `ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.datetime_type`.

    This setting controls what native type Active Record should use when you call `datetime` in
    a migration or schema. It takes a symbol which must correspond to one of the configured
    `NATIVE_DATABASE_TYPES`. The default is `:timestamp`, meaning `t.datetime` in a migration
    will create a "timestamp without time zone" column. To use "timestamp with time zone",
    change this to `:timestamptz` in an initializer.

    You should run `bin/rails db:migrate` to rebuild your schema.rb if you change this.

    *Alex Ghiculescu*

*   PostgreSQL: handle `timestamp with time zone` columns correctly in `schema.rb`.

    Previously they dumped as `t.datetime :column_name`, now they dump as `t.timestamptz :column_name`,
    and are created as `timestamptz` columns when the schema is loaded.

    *Alex Ghiculescu*

*   Removing trailing whitespace when matching columns in
    `ActiveRecord::Sanitization.disallow_raw_sql!`.

    *Gannon McGibbon*, *Adrian Hirt*

*   Expose a way for applications to set a `primary_abstract_class`.

    Multiple database applications that use a primary abstract class that is not
    named `ApplicationRecord` can now set a specific class to be the `primary_abstract_class`.

    ```ruby
    class PrimaryApplicationRecord
      self.primary_abstract_class
    end
    ```

    When an application boots it automatically connects to the primary or first database in the
    database configuration file. In a multiple database application that then call `connects_to`
    needs to know that the default connection is the same as the `ApplicationRecord` connection.
    However, some applications have a differently named `ApplicationRecord`. This prevents Active
    Record from opening duplicate connections to the same database.

    *Eileen M. Uchitelle*, *John Crepezzi*

*   Support hash config for `structure_dump_flags` and `structure_load_flags` flags.
    Now that Active Record supports multiple databases configuration,
    we need a way to pass specific flags for dump/load databases since
    the options are not the same for different adapters.
    We can use in the original way:

    ```ruby
    ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-defaults', '--skip-add-drop-table']
    # or
    ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = '--no-defaults --skip-add-drop-table'
    ```

    And also use it passing a hash, with one or more keys, where the key
    is the adapter

    ```ruby
    ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = {
      mysql2: ['--no-defaults', '--skip-add-drop-table'],
      postgres: '--no-tablespaces'
    }
    ```

    *Gustavo Gonzalez*

*   Connection specification now passes the "url" key as a configuration for the
    adapter if the "url" protocol is "jdbc", "http", or "https". Previously only
    urls with the "jdbc" prefix were passed to the Active Record Adapter, others
    are assumed to be adapter specification urls.

    Fixes #41137.

    *Jonathan Bracy*

*   Allow to opt-out of `strict_loading` mode on a per-record base.

    This is useful when strict loading is enabled application wide or on a
    model level.

    ```ruby
    class User < ApplicationRecord
      has_many :bookmarks
      has_many :articles, strict_loading: true
    end

    user = User.first
    user.articles                        # => ActiveRecord::StrictLoadingViolationError
    user.bookmarks                       # => #<ActiveRecord::Associations::CollectionProxy>

    user.strict_loading!(true)           # => true
    user.bookmarks                       # => ActiveRecord::StrictLoadingViolationError

    user.strict_loading!(false)          # => false
    user.bookmarks                       # => #<ActiveRecord::Associations::CollectionProxy>
    user.articles.strict_loading!(false) # => #<ActiveRecord::Associations::CollectionProxy>
    ```

    *Ayrton De Craene*

*   Add `FinderMethods#sole` and `#find_sole_by` to find and assert the
    presence of exactly one record.

    Used when you need a single row, but also want to assert that there aren't
    multiple rows matching the condition; especially for when database
    constraints aren't enough or are impractical.

    ```ruby
    Product.where(["price = %?", price]).sole
    # => ActiveRecord::RecordNotFound      (if no Product with given price)
    # => #<Product ...>                    (if one Product with given price)
    # => ActiveRecord::SoleRecordExceeded  (if more than one Product with given price)

    user.api_keys.find_sole_by(key: key)
    # as above
    ```

    *Asherah Connor*

*   Makes `ActiveRecord::AttributeMethods::Query` respect the getter overrides defined in the model.

    Before:

    ```ruby
    class User
      def admin
        false # Overriding the getter to always return false
      end
    end

    user = User.first
    user.update(admin: true)

    user.admin # false (as expected, due to the getter overwrite)
    user.admin? # true (not expected, returned the DB column value)
    ```

    After this commit, `user.admin?` above returns false, as expected.

    Fixes #40771.

    *Felipe*

*   Allow delegated_type to be specified primary_key and foreign_key.

    Since delegated_type assumes that the foreign_key ends with `_id`,
    `singular_id` defined by it does not work when the foreign_key does
    not end with `id`. This change fixes it by taking into account
    `primary_key` and `foreign_key` in the options.

    *Ryota Egusa*

*   Expose an `invert_where` method that will invert all scope conditions.

    ```ruby
    class User
      scope :active, -> { where(accepted: true, locked: false) }
    end

    User.active
    # ... WHERE `accepted` = 1 AND `locked` = 0

    User.active.invert_where
    # ... WHERE NOT (`accepted` = 1 AND `locked` = 0)
    ```

    *Kevin Deisz*

*   Restore possibility of passing `false` to :polymorphic option of `belongs_to`.

    Previously, passing `false` would trigger the option validation logic
    to throw an error saying :polymorphic would not be a valid option.

    *glaszig*

*   Remove deprecated `database` kwarg from `connected_to`.

    *Eileen M. Uchitelle*, *John Crepezzi*

*   Allow adding nonnamed expression indexes to be revertible.

    Previously, the following code would raise an error, when executed while rolling back,
    and the index name should be specified explicitly. Now, the index name is inferred
    automatically.

    ```ruby
    add_index(:items, "to_tsvector('english', description)")
    ```

    Fixes #40732.

    *fatkodima*

*   Only warn about negative enums if a positive form that would cause conflicts exists.

    Fixes #39065.

    *Alex Ghiculescu*

*   Add option to run `default_scope` on all queries.

    Previously, a `default_scope` would only run on select or insert queries. In some cases, like non-Rails tenant sharding solutions, it may be desirable to run `default_scope` on all queries in order to ensure queries are including a foreign key for the shard (i.e. `blog_id`).

    Now applications can add an option to run on all queries including select, insert, delete, and update by adding an `all_queries` option to the default scope definition.

    ```ruby
    class Article < ApplicationRecord
      default_scope -> { where(blog_id: Current.blog.id) }, all_queries: true
    end
    ```

    *Eileen M. Uchitelle*

*   Add `where.associated` to check for the presence of an association.

    ```ruby
    # Before:
    account.users.joins(:contact).where.not(contact_id: nil)

    # After:
    account.users.where.associated(:contact)
    ```

    Also mirrors `where.missing`.

    *Kasper Timm Hansen*

*   Allow constructors (`build_association` and `create_association`) on
    `has_one :through` associations.

    *Santiago Perez Perret*


Please check [6-1-stable](https://github.com/rails/rails/blob/6-1-stable/activerecord/CHANGELOG.md) for previous changes.
