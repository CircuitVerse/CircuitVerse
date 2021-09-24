module Aws
  module Record
    class BuildableSearch
      SUPPORTED_OPERATIONS = [:query, :scan]

      # This should never be called directly, rather it is called by the
      # #build_query or #build_scan methods of your aws-record model class.
      def initialize(opts)
        operation = opts[:operation]
        model = opts[:model]
        if SUPPORTED_OPERATIONS.include?(operation)
          @operation = operation
        else
          raise ArgumentError.new("Unsupported operation: #{operation}")
        end
        @model = model
        @params = {}
        @next_name = "BUILDERA"
        @next_value = "buildera"
      end

      # If you are querying or scanning on an index, you can specify it with
      # this builder method. Provide the symbol of your index as defined on your
      # model class.
      def on_index(index)
        @params[:index_name] = index
        self
      end

      # If true, will perform your query or scan as a consistent read. If false,
      # the query or scan is eventually consistent.
      def consistent_read(b)
        @params[:consistent_read] = b
        self
      end

      # For the scan operation, you can split your scan into multiple segments
      # to be scanned in parallel. If you wish to do this, you can use this
      # builder method to provide the :total_segments of your parallel scan and
      # the :segment number of this scan.
      def parallel_scan(opts)
        unless @operation == :scan
          raise ArgumentError.new("parallel_scan is only supported for scans")
        end
        unless opts[:total_segments] && opts[:segment]
          raise ArgumentError.new("Must specify :total_segments and :segment in a parallel scan.")
        end
        @params[:total_segments] = opts[:total_segments]
        @params[:segment] = opts[:segment]
        self
      end

      # For a query operation, you can use this to set if you query is in
      # ascending or descending order on your range key. By default, a query is
      # run in ascending order.
      def scan_ascending(b)
        unless @operation == :query
          raise ArgumentError.new("scan_ascending is only supported for queries.")
        end
        @params[:scan_index_forward] = b
        self
      end

      # If you have an exclusive start key for your query or scan, you can
      # provide it with this builder method. You should not use this if you are
      # querying or scanning without a set starting point, as the
      # {Aws::Record::ItemCollection} class handles pagination automatically
      # for you.
      def exclusive_start_key(key)
        @params[:exclusive_start_key] = key
        self
      end

      # Provide a key condition expression for your query using a substitution
      # expression.
      #
      # @example Building a simple query with a key expression:
      #   # Example model class
      #   class ExampleTable
      #     include Aws::Record
      #     string_attr  :uuid, hash_key: true
      #     integer_attr :id,   range_key: true
      #     string_attr  :body
      #   end
      #
      #   q = ExampleTable.build_query.key_expr(
      #         ":uuid = ? AND :id > ?", "smpl-uuid", 100
      #       ).complete!
      #   q.to_a # You can use this like any other query result in aws-record
      def key_expr(statement_str, *subs)
        unless @operation == :query
          raise ArgumentError.new("key_expr is only supported for queries.")
        end
        names = @params[:expression_attribute_names]
        if names.nil?
          @params[:expression_attribute_names] = {}
          names = @params[:expression_attribute_names]
        end
        values = @params[:expression_attribute_values]
        if values.nil?
          @params[:expression_attribute_values] = {}
          values = @params[:expression_attribute_values]
        end
        _key_pass(statement_str, names)
        _apply_values(statement_str, subs, values)
        @params[:key_condition_expression] = statement_str
        self
      end

      # Provide a filter expression for your query or scan using a substitution
      # expression.
      #
      # @example Building a simple scan:
      #   # Example model class
      #   class ExampleTable
      #     include Aws::Record
      #     string_attr  :uuid, hash_key: true
      #     integer_attr :id,   range_key: true
      #     string_attr  :body
      #   end
      #
      #   scan = ExampleTable.build_scan.filter_expr(
      #     "contains(:body, ?)",
      #     "bacon"
      #   ).complete!
      # 
      def filter_expr(statement_str, *subs)
        names = @params[:expression_attribute_names]
        if names.nil?
          @params[:expression_attribute_names] = {}
          names = @params[:expression_attribute_names]
        end
        values = @params[:expression_attribute_values]
        if values.nil?
          @params[:expression_attribute_values] = {}
          values = @params[:expression_attribute_values]
        end
        _key_pass(statement_str, names)
        _apply_values(statement_str, subs, values)
        @params[:filter_expression] = statement_str
        self
      end

      # Allows you to define a projection expression for the values returned by
      # a query or scan. See
      # {https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.ProjectionExpressions.html the Amazon DynamoDB Developer Guide}
      # for more details on projection expressions. You can use the symbols from
      # your aws-record model class in a projection expression. Keys are always
      # retrieved.
      #
      # @example Scan with a projection expression:
      #   # Example model class
      #   class ExampleTable
      #     include Aws::Record
      #     string_attr  :uuid, hash_key: true
      #     integer_attr :id,   range_key: true
      #     string_attr  :body
      #     map_attr     :metadata
      #   end
      #
      #   scan = ExampleTable.build_scan.projection_expr(
      #     ":body"
      #   ).complete!
      def projection_expr(statement_str)
        names = @params[:expression_attribute_names]
        if names.nil?
          @params[:expression_attribute_names] = {}
          names = @params[:expression_attribute_names]
        end
        _key_pass(statement_str, names)
        @params[:projection_expression] = statement_str
        self
      end

      # Allows you to set a page size limit on each query or scan request.
      def limit(size)
        @params[:limit] = size
        self
      end

      # Allows you to define a callback that will determine the model class
      # to be used for each item, allowing queries to return an ItemCollection
      # with mixed models.  The provided block must return the model class based on
      # any logic on the raw item attributes or `nil` if no model applies and
      # the item should be skipped.  Note: The block only has access to raw item
      # data so attributes must be accessed using their names as defined in the
      # table, not as the symbols defined in the model class(s).
      #
      # @example Scan with heterogeneous results:
      #   # Example model classes
      #   class Model_A
      #     include Aws::Record
      #     set_table_name(TABLE_NAME)
      #
      #     string_attr :uuid, hash_key: true
      #     string_attr :class_name, range_key: true
      #
      #     string_attr :attr_a
      #   end
      #
      #   class Model_B
      #     include Aws::Record
      #     set_table_name(TABLE_NAME)
      #
      #     string_attr :uuid, hash_key: true
      #     string_attr :class_name, range_key: true
      #
      #     string_attr :attr_b
      #   end
      #
      #   # use multi_model_filter to create a query on TABLE_NAME
      #   items = Model_A.build_scan.multi_model_filter do |raw_item_attributes|
      #     case raw_item_attributes['class_name']
      #     when "A" then Model_A
      #     when "B" then Model_B
      #     else
      #       nil
      #     end
      #   end.complete!
      def multi_model_filter(proc = nil, &block)
        @params[:model_filter] = proc || block
        self
      end

      # You must call this method at the end of any query or scan you build.
      #
      # @return [Aws::Record::ItemCollection] The item collection lazy
      #   enumerable.
      def complete!
        @model.send(@operation, @params)
      end

      private
      def _key_pass(statement, names)
        statement.gsub!(/:(\w+)/) do |match|
          key = match.gsub!(':','').to_sym 
          key_name = @model.attributes.storage_name_for(key)
          if key_name
            sub_name = _next_name
            raise "Substitution collision!" if names[sub_name]
            names[sub_name] = key_name
            sub_name
          else
            raise "No such key #{key}"
          end
        end
      end

      def _apply_values(statement, subs, values)
        count = 0
        statement.gsub!(/[?]/) do |match|
          sub_value = _next_value
          raise "Substitution collision!" if values[sub_value]
          values[sub_value] = subs[count]
          count += 1
          sub_value
        end
        unless count == subs.size
          raise "Expected #{count} values in the substitution set, but found #{subs.size}"
        end
      end

      def _next_name
        ret = "#" + @next_name
        @next_name.next!
        ret
      end

      def _next_value
        ret = ":" + @next_value
        @next_value.next!
        ret
      end
    end
  end
end
