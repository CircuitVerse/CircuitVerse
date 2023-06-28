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
    module Errors

      # RecordErrors relate to the persistence of items. They include both
      # client errors and certain validation errors.
      class RecordError < RuntimeError; end

      # Raised when a required key attribute is missing from an item when
      # persistence is attempted.
      class KeyMissing < RecordError; end

      # Raised when you attempt to load a record from the database, but it does
      # not exist there.
      class NotFound < RecordError; end

      # Raised when a conditional write fails.
      class ConditionalWriteFailed < RecordError; end

      # Raised when a validation hook call to +:valid?+ fails.
      class ValidationError < RecordError; end

      # Raised when an attribute is defined that has a name collision with an
      # existing attribute.
      class NameCollision < RuntimeError; end

      # Raised when you attempt to create an attribute which has a name that
      # conflicts with reserved names (generally, defined method names). If you
      # see this error, you should change the attribute name in the model. If
      # the database uses this name, you can take advantage of the
      # +:database_attribute_name+ option in
      # {Aws::Record::Attributes::ClassMethods#attr #attr}
      class ReservedName < RuntimeError; end

      # Raised when you attempt a table migration and your model class is
      # invalid.
      class InvalidModel < RuntimeError; end

      # Raised when you attempt update/delete operations on a table that does
      # not exist.
      class TableDoesNotExist < RuntimeError; end

      class MissingRequiredConfiguration < RuntimeError; end

      # Raised when you attempt to combine your own condition expression with
      # the auto-generated condition expression from a "safe put" from saving
      # a new item in a transactional write operation. The path forward until
      # this case is supported is to use a plain "put" call, and to include
      # the key existance check yourself in your condition expression if you
      # wish to do so.
      class TransactionalSaveConditionCollision < RuntimeError; end
    end
  end
end
