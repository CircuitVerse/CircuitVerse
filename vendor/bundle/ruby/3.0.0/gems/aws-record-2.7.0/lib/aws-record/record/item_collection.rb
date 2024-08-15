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
    class ItemCollection
      include Enumerable

      def initialize(search_method, search_params, model, client)
        @search_method = search_method
        @search_params = search_params
        @model_filter = @search_params.delete(:model_filter)
        @model = model
        @client = client
      end

      # Provides an enumeration of the results of a query or scan operation on
      # your table, automatically converted into item classes.
      #
      # WARNING: This will enumerate over your entire partition in the case of
      # query, and over your entire table in the case of scan, save for key and
      # filter expressions used. This means that enumerable operations that
      # iterate over the full result set could make many network calls, or use a
      # lot of memory to build response objects. Use with caution.
      #
      # @return [Enumerable<Aws::Record>] an enumeration over the results of
      #   your query or scan request. These results are automatically converted
      #   into items on your behalf.
      def each(&block)
        return enum_for(:each) unless block_given?
        items.each_page do |page|
          @last_evaluated_key = page.last_evaluated_key
          items_array = _build_items_from_response(page.items, @model)
          items_array.each do |item|
            yield item
          end
        end
      end

      # Provides the first "page" of responses from your query operation. This
      # will only make a single client call, and will provide the items, if any
      # exist, from that response. It will not attempt to follow up on
      # pagination tokens, so this is not guaranteed to include all items that
      # match your search.
      #
      # @return [Array<Aws::Record>] an array of the record items found in the
      #   first page of reponses from the query or scan call.
      def page
        search_response = items
        @last_evaluated_key = search_response.last_evaluated_key
        _build_items_from_response(search_response.items, @model)
      end

      # Provides the pagination key most recently used by the underlying client.
      # This can be useful in the case where you're exposing pagination to an
      # outside caller, and want to be able to "resume" your scan in a new call
      # without starting over.
      #
      # @return [Hash] a hash representing an attribute key/value pair, suitable
      #   for use as the +exclusive_start_key+ in another query or scan
      #   operation. If there are no more pages in the result, will be nil.
      def last_evaluated_key
        @last_evaluated_key
      end

      # Checks if the query/scan result is completely blank.
      #
      # WARNING: This can and will query your entire partition, or scan your
      # entire table, if no results are found. Especially if your table is
      # large, use this with extreme caution.
      #
      # @return [Boolean] true if the query/scan result is empty, false
      #   otherwise.
      def empty?
        items.each_page do |page|
          return false if !page.items.empty?
        end
        true
      end

      private
      def _build_items_from_response(items, model)
        ret = []
        items.each do |item|
          model_class = @model_filter ? @model_filter.call(item) : model
          next unless model_class
          record = model_class.new
          data = record.instance_variable_get("@data")
          model_class.attributes.attributes.each do |name, attr|
            data.set_attribute(name, attr.extract(item))
          end
          data.clean!
          data.new_record = false
          ret << record
        end
        ret
      end

      def items
        @_items ||= @client.send(@search_method, @search_params)
      end

    end
  end
end
