# frozen_string_literal: true

module Aws
  module Rails
    module SqsActiveJob

      class JobRunner
        attr_reader :id, :class_name

        def initialize(message)
          @job_data = Aws::Json.load(message.data.body)
          @class_name = @job_data['job_class'].constantize
          @id = @job_data['job_id']
        end

        def run
          ActiveJob::Base.execute @job_data
        end
      end
    end
  end
end
