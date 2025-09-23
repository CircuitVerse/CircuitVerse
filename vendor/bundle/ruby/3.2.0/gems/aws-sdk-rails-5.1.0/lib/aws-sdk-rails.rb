# frozen_string_literal: true

require_relative 'aws/rails/middleware/elastic_beanstalk_sqsd'
require_relative 'aws/rails/railtie'
require_relative 'aws/rails/notifications'

module Aws
  module Rails
    VERSION = File.read(File.expand_path('../VERSION', __dir__)).strip
  end
end
