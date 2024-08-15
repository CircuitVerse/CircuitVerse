# frozen_string_literal: true

require 'aws-sdk-sqs'

module Aws
  module Rails
    module SqsActiveJob

      # A lambda event handler to run jobs from an SQS queue trigger
      # Trigger the lambda from your SQS queue
      # Configure the entrypoint to: +config/environment.Aws::Rails::SqsActiveJob.lambda_job_handler+
      # This will load your Rails environment, and then use this method as the handler.
      def self.lambda_job_handler(event:, context:)
        return 'no records to process' unless event['Records']

        event['Records'].each do |record|
          sqs_msg = to_sqs_msg(record)
          job = Aws::Rails::SqsActiveJob::JobRunner.new(sqs_msg)
          puts("Running job: #{job.id}[#{job.class_name}]")
          job.run
          sqs_msg.delete
        end
        "Processed #{event['Records'].length} jobs."
      end

      private

      def self.to_sqs_msg(record)
        msg = Aws::SQS::Types::Message.new(
          body: record['body'],
          md5_of_body: record['md5OfBody'],
          message_attributes: self.to_message_attributes(record),
          message_id: record['messageId'],
          receipt_handle: record['receiptHandle']
        )
        Aws::SQS::Message.new(
          queue_url: to_queue_url(record),
          receipt_handle: msg.receipt_handle,
          data: msg,
          client: Aws::Rails::SqsActiveJob.config.client
        )
      end

      def self.to_message_attributes(record)
        record['messageAttributes'].each_with_object({}) do |(key, value), acc|
          acc[key] = {
            string_value: value['stringValue'],
            binary_value: value['binaryValue'],
            string_list_values: ['stringListValues'],
            binary_list_values: value['binaryListValues'],
            data_type: value['dataType']
          }
        end
      end

      def self.to_queue_url(record)
        source_arn = record['eventSourceARN']
        raise ArgumentError, "Invalid queue arn: #{source_arn}" unless Aws::ARNParser.arn?(source_arn)

        arn = Aws::ARNParser.parse(source_arn)
        sfx = Aws::Partitions::EndpointProvider.dns_suffix_for(arn.region)
        "https://sqs.#{arn.region}.#{sfx}/#{arn.account_id}/#{arn.resource}"
      end
    end
  end
end
