# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/version-3/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE


module Aws::SESV2
  # @api private
  module Endpoints

    class SendBulkEmail
      def self.build(context)
        Aws::SESV2::EndpointParameters.create(
          context.config,
          endpoint_id: context.params[:endpoint_id],
        )
      end
    end

    class SendEmail
      def self.build(context)
        Aws::SESV2::EndpointParameters.create(
          context.config,
          endpoint_id: context.params[:endpoint_id],
        )
      end
    end


    def self.parameters_for_operation(context)
      case context.operation_name
      when :send_bulk_email
        SendBulkEmail.build(context)
      when :send_email
        SendEmail.build(context)
      else
        Aws::SESV2::EndpointParameters.create(context.config)
      end
    end
  end
end
