# Copyright 2015-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not
# use this file except in compliance with the License. A copy of the License is
# located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions
# and limitations under the License.

module Aws
  module Record
    module ItemOperations

      # @api private
      def self.included(sub_class)
        sub_class.extend(ItemOperationsClassMethods)
      end

      # Saves this instance of an item to Amazon DynamoDB. If this item is "new"
      # as defined by having new or altered key attributes, will attempt a
      # conditional
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method Aws::DynamoDB::Client#put_item}
      # call, which will not overwrite an existing item. If the item only has
      # altered non-key attributes, will perform an
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#update_item-instance_method Aws::DynamoDB::Client#update_item}
      # call. Uses this item instance's attributes in order to build the
      # request on your behalf.
      #
      # You can use the +:force+ option to perform a simple put/overwrite
      # without conditional validation or update logic.
      #
      # @param [Hash] opts
      # @option opts [Boolean] :force if true, will save as a put operation and
      #  overwrite any existing item on the remote end. Otherwise, and by
      #  default, will either perform a conditional put or an update call.
      # @raise [Aws::Record::Errors::KeyMissing] if a required key attribute
      #  does not have a value within this item instance.
      # @raise [Aws::Record::Errors::ConditionalWriteFailed] if a conditional
      #  put fails because the item exists on the remote end.
      # @raise [Aws::Record::Errors::ValidationError] if the item responds to
      #  +:valid?+ and that call returned false. In such a case, checking root
      #  cause is dependent on the validation library you are using.
      def save!(opts = {})
        ret = save(opts)
        if ret
          ret
        else
          raise Errors::ValidationError.new("Validation hook returned false!")
        end
      end

      # Saves this instance of an item to Amazon DynamoDB. If this item is "new"
      # as defined by having new or altered key attributes, will attempt a
      # conditional
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#put_item-instance_method Aws::DynamoDB::Client#put_item}
      # call, which will not overwrite an existing item. If the item only has
      # altered non-key attributes, will perform an
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#update_item-instance_method Aws::DynamoDB::Client#update_item}
      # call. Uses this item instance's attributes in order to build the
      # request on your behalf.
      #
      # You can use the +:force+ option to perform a simple put/overwrite
      # without conditional validation or update logic.
      #
      # @param [Hash] opts
      # @option opts [Boolean] :force if true, will save as a put operation and
      #  overwrite any existing item on the remote end. Otherwise, and by
      #  default, will either perform a conditional put or an update call.
      # @return false if the record is invalid as defined by an attempt to call
      #  +valid?+ on this item, if that method exists. Otherwise, returns client
      #  call return value.
      def save(opts = {})
        if _invalid_record?(opts)
          false
        else
          _perform_save(opts)
        end
      end


      # Assigns the attributes provided onto the model.
      #
      # @example Usage Example
      #   class MyModel
      #     include Aws::Record
      #     integer_attr :uuid,   hash_key: true
      #     string_attr  :name, range_key: true
      #     integer_attr :age
      #     float_attr   :height
      #   end
      #
      #   model = MyModel.new(id: 4, name: "John", age: 4, height: 70.5)
      #   model.age    # => 4
      #   model.height # => 70.5
      #   model.save
      #   model.dirty? # => false  
      # 
      #   model.assign_attributes(age: 5, height: 150.75)
      #   model.age    # => 5
      #   model.height # => 150.75
      #   model.dirty? # => true
      #   
      #
      # @param [Hash] opts
      def assign_attributes(opts)
        opts.each do |field, new_value|
          field = field.to_sym
          setter = "#{field}="
          raise ArgumentError.new "Invalid field: #{field} for model" unless respond_to?(setter)
          public_send(setter, new_value)
        end
      end

      # Mass assigns the attributes to the model and then performs a save
      #
      # You can use the +:force+ option to perform a simple put/overwrite
      # without conditional validation or update logic.
      #
      # Note that aws-record allows you to change your model's key values,
      # but this will be interpreted as persisting a new item to your DynamoDB
      # table
      #
      # @example Usage Example
      #   class MyModel
      #     include Aws::Record
      #     integer_attr :uuid,   hash_key: true
      #     string_attr  :name, range_key: true
      #     integer_attr :age
      #     float_attr   :height
      #   end
      #
      #   model = MyModel.new(id: 4, name: "John", age: 4, height: 70.5)
      #   model.age    # => 4
      #   model.height # => 70.5
      #   model.save
      #   model.dirty? # => false  
      # 
      #   model.update(age: 5, height: 150.75)
      #   model.age    # => 5
      #   model.height # => 150.75
      #   model.dirty? # => false
      #
      # 
      # @param [Hash] new_param, contains the new parameters for the model
      #
      # @param [Hash] opts
      # @option opts [Boolean] :force if true, will save as a put operation and
      #  overwrite any existing item on the remote end. Otherwise, and by
      #  default, will either perform a conditional put or an update call.
      # @return false if the record is invalid as defined by an attempt to call
      #  +valid?+ on this item, if that method exists. Otherwise, returns client
      #  call return value.
      def update(new_params, opts = {})
        assign_attributes(new_params)
        save(opts)
      end

      # Updates model attributes and validates new values
      #
      # You can use the +:force+ option to perform a simple put/overwrite
      # without conditional validation or update logic.
      #
      # Note that aws-record allows you to change your model's key values,
      # but this will be interpreted as persisting a new item to your DynamoDB
      # table
      # 
      # @param [Hash] new_param, contains the new parameters for the model
      #
      # @param [Hash] opts
      # @option opts [Boolean] :force if true, will save as a put operation and
      #  overwrite any existing item on the remote end. Otherwise, and by
      #  default, will either perform a conditional put or an update call.
      # @return The update mode if the update is successful
      #
      # @raise [Aws::Record::Errors::ValidationError] if any new values
      #  violate the models validations.
      def update!(new_params, opts = {})
        assign_attributes(new_params)
        save!(opts)
      end

      # Deletes the item instance that matches the key values of this item
      # instance in Amazon DynamoDB. Uses the
      # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#delete_item-instance_method Aws::DynamoDB::Client#delete_item}
      # API.
      def delete!
        dynamodb_client.delete_item(
          table_name: self.class.table_name,
          key: key_values
        )
        self.instance_variable_get("@data").destroyed = true
      end

      private
      def _invalid_record?(opts)
        if self.respond_to?(:valid?)
          if !self.valid?
            true
          else
            false
          end
        else
          false
        end
      end

      def _perform_save(opts)
        force = opts[:force]
        expect_new = expect_new_item?
        if force
          dynamodb_client.put_item(
            table_name: self.class.table_name,
            item: _build_item_for_save
          )
        elsif expect_new
          put_opts = {
            table_name: self.class.table_name,
            item: _build_item_for_save
          }.merge(prevent_overwrite_expression)
          begin
            dynamodb_client.put_item(put_opts)
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            raise Errors::ConditionalWriteFailed.new(
              "Conditional #put_item call failed! Check that conditional write"\
                " conditions are met, or include the :force option to clobber"\
                " the remote item."
            )
          end
        else
          update_pairs = _dirty_changes_for_update
          update_tuple = self.class.send(
            :_build_update_expression,
            update_pairs
          )
          if update_tuple
            uex, exp_attr_names, exp_attr_values = update_tuple
            request_opts = {
              table_name: self.class.table_name,
              key: key_values,
              update_expression: uex,
              expression_attribute_names: exp_attr_names,
            }
            request_opts[:expression_attribute_values] = exp_attr_values unless exp_attr_values.empty?
            dynamodb_client.update_item(request_opts)
          else
            dynamodb_client.update_item(
              table_name: self.class.table_name,
              key: key_values
            )
          end
        end
        data = self.instance_variable_get("@data")
        data.destroyed = false
        data.new_record = false
        true
      end

      def _build_item_for_save
        validate_key_values
        @data.populate_default_values
        @data.build_save_hash
      end

      def key_values
        validate_key_values
        attributes = self.class.attributes
        self.class.keys.inject({}) do |acc, (_, attr_name)|
          db_name = attributes.storage_name_for(attr_name)
          acc[db_name] = attributes.attribute_for(attr_name).
            serialize(@data.raw_value(attr_name))
          acc
        end
      end

      def validate_key_values
        missing = missing_key_values
        unless missing.empty?
          raise Errors::KeyMissing.new(
            "Missing required keys: #{missing.join(', ')}"
          )
        end
      end

      def missing_key_values
        self.class.keys.inject([]) do |acc, key|
          acc << key.last if @data.raw_value(key.last).nil?
          acc
        end
      end

      def expect_new_item?
        # Algorithm: Are keys dirty? If so, we treat as new.
        self.class.keys.any? do |_, attr_name|
          attribute_dirty?(attr_name)
        end
      end

      def prevent_overwrite_expression
        conditions = []
        expression_attribute_names = {}
        keys = self.class.instance_variable_get("@keys")
        # Hash Key
        conditions << "attribute_not_exists(#H)"
        expression_attribute_names["#H"] = keys.hash_key_attribute.database_name
        # Range Key
        if self.class.range_key
          conditions << "attribute_not_exists(#R)"
          expression_attribute_names["#R"] = keys.range_key_attribute.database_name
        end
        {
          condition_expression: conditions.join(" and "),
          expression_attribute_names: expression_attribute_names
        }
      end

      def _dirty_changes_for_update
        attributes = self.class.attributes
        ret = dirty.inject({}) do |acc, attr_name|
          acc[attr_name] = @data.raw_value(attr_name)
          acc
        end
        ret
      end

      module ItemOperationsClassMethods

        # @example Usage Example
        #   check_exp = Model.transact_check_expression(
        #     key: { uuid: "foo" },
        #     condition_expression: "size(#T) <= :v",
        #     expression_attribute_names: {
        #       "#T" => "body"
        #     },
        #     expression_attribute_values: {
        #       ":v" => 1024
        #     }
        #   )
        # 
        # Allows you to build a "check" expression for use in transactional
        # write operations.
        #
        # @param [Hash] opts Options matching the :condition_check contents in
        #   the
        #   {https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html#transact_write_items-instance_method Aws::DynamoDB::Client#transact_write_items}
        #   API, with the exception that keys will be marshalled for you, and
        #   the table name will be provided for you by the operation.
        # @return [Hash] Options suitable to be used as a check expression when
        #   calling the +#transact_write+ operation.
        def transact_check_expression(opts)
          # need to transform the key, and add the table name
          opts = opts.dup
          key = opts.delete(:key)
          check_key = {}
          @keys.keys.each_value do |attr_sym|
            unless key[attr_sym]
              raise Errors::KeyMissing.new(
                "Missing required key #{attr_sym} in #{key}"
              )
            end
            attr_name = attributes.storage_name_for(attr_sym)
            check_key[attr_name] = attributes.attribute_for(attr_sym).
              serialize(key[attr_sym])
          end
          opts[:key] = check_key
          opts[:table_name] = table_name
          opts
        end

        def tfind_opts(opts)
          opts = opts.dup
          key = opts.delete(:key)
          request_key = {}
          @keys.keys.each_value do |attr_sym|
            unless key[attr_sym]
              raise Errors::KeyMissing.new(
                "Missing required key #{attr_sym} in #{key}"
              )
            end
            attr_name = attributes.storage_name_for(attr_sym)
            request_key[attr_name] = attributes.attribute_for(attr_sym).
              serialize(key[attr_sym])
          end
          # this is a :get item used by #transact_get_items, with the exception
          # of :model_class which needs to be removed before passing along
          opts[:key] = request_key
          opts[:table_name] = table_name
          {
            model_class: self,
            get: opts
          }
        end

        # @example Usage Example
        #   class Table
        #     include Aws::Record
        #     string_attr :hk, hash_key: true
        #     string_attr :rk, range_key: true
        #   end
        #   
        #   results = Table.transact_find(
        #     transact_items: [
        #       {key: { hk: "hk1", rk: "rk1"}},
        #       {key: { hk: "hk2", rk: "rk2"}}
        #     ]
        #   ) # => results.responses contains nil or instances of Table
        #
        # Provides a way to run a transactional find across multiple DynamoDB
        # items, including transactions which get items across multiple actual
        # or virtual tables.
        #
        # @param [Hash] opts Options to pass through to
        #   {https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html#transact_get_items-instance_method Aws::DynamoDB::Client#transact_get_items},
        #   with the exception of the :transact_items array, which uses the
        #   +#tfind_opts+ operation on your model class to provide extra
        #   metadata used to marshal your items after retrieval.
        # @option opts [Array] :transact_items A set of options describing
        #   instances of the model class to return.
        # @return [OpenStruct] Structured like the client API response from
        #   +#transact_get_items+, except that the +responses+ member contains
        #   +Aws::Record+ items marshaled into the model class used to call
        #   this method. See the usage example.
        def transact_find(opts)
          opts = opts.dup
          transact_items = opts.delete(:transact_items)
          global_transact_items = transact_items.map do |topts|
            tfind_opts(topts)
          end
          opts[:transact_items] = global_transact_items
          opts[:client] = dynamodb_client
          Transactions.transact_find(opts)
        end

        # @example Usage Example
        #   class MyModel
        #     include Aws::Record
        #     integer_attr :id,   hash_key: true
        #     string_attr  :name, range_key: true
        #   end
        #
        #   MyModel.find(id: 1, name: "First")
        #
        # @param [Hash] opts attribute-value pairs for the key you wish to
        #  search for.
        # @return [Aws::Record] builds and returns an instance of your model.
        # @raise [Aws::Record::Errors::KeyMissing] if your option parameters do
        #  not include all table keys.
        def find(opts)
          find_with_opts(key: opts)
        end

        # @example Usage Example
        #   class MyModel
        #     include Aws::Record
        #     integer_attr :id,   hash_key: true
        #     string_attr  :name, range_key: true
        #   end
        #
        #   MyModel.find_with_opts(
        #     key: { id: 1, name: "First" },
        #     consistent_read: true
        #   )
        #
        # Note that +#find_with_opts+ will pass through all options other than
        # +:key+ unaltered to the underlying +Aws::DynamoDB::Client#get_item+
        # request. You should ensure that you have an aws-sdk gem version which
        # supports the options you are including, and avoid adding options not
        # recognized by the underlying client to avoid runtime exceptions.
        #
        # @param [Hash] opts Options to pass through to the DynamoDB #get_item
        #  request. The +:key+ option is a special case where attributes are
        #  serialized and translated for you similar to the #find method.
        # @option opts [Hash] :key attribute-value pairs for the key you wish to
        #  search for.
        # @return [Aws::Record] builds and returns an instance of your model.
        # @raise [Aws::Record::Errors::KeyMissing] if your option parameters do
        #  not include all table keys.
        def find_with_opts(opts)
          key = opts.delete(:key)
          request_key = {}
          @keys.keys.each_value do |attr_sym|
            unless key[attr_sym]
              raise Errors::KeyMissing.new(
                "Missing required key #{attr_sym} in #{key}"
              )
            end
            attr_name = attributes.storage_name_for(attr_sym)
            request_key[attr_name] = attributes.attribute_for(attr_sym).
              serialize(key[attr_sym])
          end
          request_opts = {
            table_name: table_name,
            key: request_key
          }.merge(opts)
          resp = dynamodb_client.get_item(request_opts)
          if resp.item.nil?
            nil
          else
            build_item_from_resp(resp)
          end
        end

        # @example Usage Example
        #   class MyModel
        #     include Aws::Record
        #     integer_attr :id,   hash_key: true
        #     string_attr  :name, range_key: true
        #     string_attr  :body
        #     boolean_attr :sir_not_appearing_in_this_example
        #   end
        #
        #   MyModel.update(id: 1, name: "First", body: "Hello!")
        #
        # Performs an
        # {http://docs.aws.amazon.com/sdkforruby/api/Aws/DynamoDB/Client.html#update_item-instance_method Aws::DynamoDB::Client#update_item}
        # call immediately on the table, using the attribute key/value pairs
        # provided.
        #
        # @param [Hash] opts attribute-value pairs for the update operation you
        #  wish to perform. You must include all key attributes for a valid
        #  call, then you may optionally include any other attributes that you
        #  wish to update.
        # @raise [Aws::Record::Errors::KeyMissing] if your option parameters do
        #  not include all table keys.
        def update(opts)
          key = {}
          updates = {}
          @keys.keys.each_value do |attr_sym|
            unless value = opts.delete(attr_sym)
              raise Errors::KeyMissing.new(
                "Missing required key #{attr_sym} in #{opts}"
              )
            end
            attr_name = attributes.storage_name_for(attr_sym)
            key[attr_name] = attributes.attribute_for(attr_sym).serialize(value)
          end
          request_opts = {
            table_name: table_name,
            key: key
          }
          update_tuple = _build_update_expression(opts)
          unless update_tuple.nil?
            uex, exp_attr_names, exp_attr_values = update_tuple
            request_opts[:update_expression] = uex
            request_opts[:expression_attribute_names] = exp_attr_names
            request_opts[:expression_attribute_values] = exp_attr_values unless exp_attr_values.empty?
          end
          dynamodb_client.update_item(request_opts)
        end

        private
        def _build_update_expression(attr_value_pairs)
          set_expressions = []
          remove_expressions = []
          exp_attr_names = {}
          exp_attr_values = {}
          name_sub_token = "UE_A"
          value_sub_token = "ue_a"
          attr_value_pairs.each do |attr_sym, value|
            name_sub = "#" + name_sub_token
            value_sub = ":" + value_sub_token
            name_sub_token = name_sub_token.succ
            value_sub_token = value_sub_token.succ

            attribute = attributes.attribute_for(attr_sym)
            attr_name = attributes.storage_name_for(attr_sym)
            exp_attr_names[name_sub] = attr_name
            if _update_type_remove?(attribute, value)
              remove_expressions << "#{name_sub}"
            else
              set_expressions << "#{name_sub} = #{value_sub}"
              exp_attr_values[value_sub] = attribute.serialize(value)
            end
          end
          update_expressions = []
          unless set_expressions.empty?
            update_expressions << "SET " + set_expressions.join(", ")
          end
          unless remove_expressions.empty?
            update_expressions << "REMOVE " + remove_expressions.join(", ")
          end
          if update_expressions.empty?
            nil
          else
            [update_expressions.join(" "), exp_attr_names, exp_attr_values]
          end
        end

        def build_item_from_resp(resp)
          record = new
          data = record.instance_variable_get("@data")
          attributes.attributes.each do |name, attr|
            data.set_attribute(name, attr.extract(resp.item))
            data.new_record = false
          end
          record
        end

        def _update_type_remove?(attribute, value)
          value.nil? && !attribute.persist_nil?
        end
      end

    end
  end
end
