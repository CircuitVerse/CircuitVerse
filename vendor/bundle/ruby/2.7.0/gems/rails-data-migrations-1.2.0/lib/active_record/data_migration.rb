require 'rails/version'

module ActiveRecord
  class DataMigration < (Rails::VERSION::MAJOR >= 5 ? Migration[5.0] : Migration)
    # base class (extend with any useful helpers)

    def down
      raise IrreversibleMigration
    end
  end
end