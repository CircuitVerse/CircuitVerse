# Creates DATETIME(3) column types by default which support microseconds.
# Without it, only regular (second precise) DATETIME columns are created.
if defined?(ActiveRecord)
  module ActiveRecord::ConnectionAdapters
    if defined?(AbstractMysqlAdapter)
      AbstractMysqlAdapter::NATIVE_DATABASE_TYPES[:datetime][:limit] = 3
    end
  end
end