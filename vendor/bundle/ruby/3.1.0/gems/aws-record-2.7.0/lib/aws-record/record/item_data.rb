# Copyright 2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

    # @api private
    class ItemData
      def initialize(model_attributes, opts)
        @data = {}
        @clean_copies = {}
        @dirty_flags = {}
        @model_attributes = model_attributes
        @track_mutations = opts[:track_mutations]
        @track_mutations = true if opts[:track_mutations].nil?
        @new_record = true
        @destroyed = false

        populate_default_values
      end
      
      attr_accessor :new_record, :destroyed

      def get_attribute(name)
        @model_attributes.attribute_for(name).type_cast(@data[name])
      end

      def set_attribute(name, value)
        @data[name] = value
      end

      def new_record?
        @new_record
      end

      def destroyed?
        @destroyed
      end

      def persisted?
        !(new_record? || destroyed?)
      end

      def raw_value(name)
        @data[name]
      end

      def clean!
        @dirty_flags = {}
        @model_attributes.attributes.each_key do |name|
          populate_default_values
          value = get_attribute(name)
          if @track_mutations
            @clean_copies[name] = _deep_copy(value)
          else
            @clean_copies[name] = value
          end
        end
      end

      def attribute_dirty?(name)
        if @dirty_flags[name]
          true
        else
          value = get_attribute(name)
          value != @clean_copies[name]
        end
      end

      def attribute_was(name)
        @clean_copies[name]
      end

      def attribute_dirty!(name)
        @dirty_flags[name] = true
      end

      def dirty
        @model_attributes.attributes.keys.inject([]) do |acc, name|
          acc << name if attribute_dirty?(name)
          acc
        end
      end

      def dirty?
        dirty.empty? ? false : true
      end

      def rollback_attribute!(name)
        if attribute_dirty?(name)
          @dirty_flags.delete(name)
          set_attribute(name, attribute_was(name))
        end
        get_attribute(name)
      end

      def hash_copy
        @data.dup
      end

      def build_save_hash
        @data.inject({}) do |acc, name_value_pair|
          attr_name, raw_value = name_value_pair
          attribute = @model_attributes.attribute_for(attr_name)
          if !raw_value.nil? || attribute.persist_nil?
            db_name = attribute.database_name
            acc[db_name] = attribute.serialize(raw_value)
          end
          acc
        end
      end

      def populate_default_values
        @model_attributes.attributes.each do |name, attribute|
          unless (default_value = attribute.default_value).nil?
            if @data[name].nil? && @data[name].nil?
              @data[name] = default_value
            end
          end
        end
      end

      private
      def _deep_copy(obj)
        Marshal.load(Marshal.dump(obj))
      end
      
    end

  end
end
