# frozen_string_literal: true

require "arel/errors"

require "arel/crud"
require "arel/factory_methods"

require "arel/expressions"
require "arel/predications"
require "arel/window_predications"
require "arel/math"
require "arel/alias_predication"
require "arel/order_predications"
require "arel/table"
require "arel/attributes"

require "arel/visitors"
require "arel/collectors/sql_string"

require "arel/tree_manager"
require "arel/insert_manager"
require "arel/select_manager"
require "arel/update_manager"
require "arel/delete_manager"
require "arel/nodes"

module Arel
  VERSION = "10.0.0"

  # Wrap a known-safe SQL string for passing to query methods, e.g.
  #
  #   Post.order(Arel.sql("length(title)")).last
  #
  # Great caution should be taken to avoid SQL injection vulnerabilities.
  # This method should not be used with unsafe values such as request
  # parameters or model attributes.
  def self.sql(raw_sql)
    Arel::Nodes::SqlLiteral.new raw_sql
  end

  def self.star # :nodoc:
    sql "*"
  end

  def self.arel_node?(value) # :nodoc:
    value.is_a?(Arel::Node) || value.is_a?(Arel::Attribute) || value.is_a?(Arel::Nodes::SqlLiteral)
  end

  def self.fetch_attribute(value) # :nodoc:
    case value
    when Arel::Nodes::Between, Arel::Nodes::In, Arel::Nodes::NotIn, Arel::Nodes::Equality, Arel::Nodes::NotEqual, Arel::Nodes::LessThan, Arel::Nodes::LessThanOrEqual, Arel::Nodes::GreaterThan, Arel::Nodes::GreaterThanOrEqual
      if value.left.is_a?(Arel::Attributes::Attribute)
        yield value.left
      elsif value.right.is_a?(Arel::Attributes::Attribute)
        yield value.right
      end
    end
  end

  ## Convenience Alias
  Node = Arel::Nodes::Node # :nodoc:
end
