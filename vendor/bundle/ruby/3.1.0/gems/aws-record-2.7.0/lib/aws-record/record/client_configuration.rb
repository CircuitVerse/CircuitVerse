# Copyright 2015-2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
    module ClientConfiguration
      # Configures the Amazon DynamoDB client used by this class and all
      # instances of this class.
      #
      # Please note that this method is also called internally when you first
      # attempt to perform an operation against the remote end, if you have not
      # already configured a client. As such, please read and understand the
      # documentation in the AWS SDK for Ruby around
      # {http://docs.aws.amazon.com/sdkforruby/api/index.html#Configuration configuration}
      # to ensure you understand how default configuration behavior works. When
      # in doubt, call this method to ensure your client is configured the way
      # you want it to be configured.
      #
      # @param [Hash] opts the options you wish to use to create the client.
      #  Note that if you include the option +:client+, all other options
      #  will be ignored. See the documentation for other options in the
      #  {https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html#initialize-instance_method AWS SDK for Ruby}.
      # @option opts [Aws::DynamoDB::Client] :client allows you to pass in your
      #  own pre-configured client.
      def configure_client(opts = {})
        @dynamodb_client = _build_client(opts)
      end

      # Gets the
      # {https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/DynamoDB/Client.html}
      # instance that Transactions use. When called for the first time, if
      # {#configure_client} has not yet been called, will configure a new
      # client for you with default parameters.
      #
      # @return [Aws::DynamoDB::Client] the Amazon DynamoDB client instance.
      def dynamodb_client
        @dynamodb_client ||= configure_client
      end

      private

      def _build_client(opts = {})
        provided_client = opts.delete(:client)
        opts[:user_agent_suffix] = _user_agent(opts.delete(:user_agent_suffix))
        provided_client || Aws::DynamoDB::Client.new(opts)
      end

      def _user_agent(custom)
        custom || " aws-record/#{VERSION}"
      end
    end
  end
end
