if !defined?(Aws::S3::Resource) or !defined?(Aws::Credentials)
  raise "Error: `Aws::S3::Resource` and/or `Aws::Credentials` are not defined.\n\n"\
        "Please `require 'aws-sdk'` - or another library that defines these classes."
end

module SitemapGenerator
  # Class for uploading sitemaps to an S3 bucket using the AWS SDK gem.
  class AwsSdkAdapter
    # Specify your AWS bucket name, credentials, and/or region.  By default
    # the AWS SDK will auto-detect your credentials and region, but you can use
    # the following options to configure - or override - them manually:
    #
    # Options:
    #   :aws_access_key_id [String] Your AWS access key id
    #   :aws_secret_access_key [String] Your AWS secret access key
    #   :aws_region [String] Your AWS region
    #
    # Requires Aws::S3::Resource and Aws::Credentials to be defined.
    #
    # @param [String] bucket Name of the S3 bucket
    # @param [Hash] options AWS credential overrides, see above
    def initialize(bucket, options = {})
      @bucket = bucket
      @aws_access_key_id = options[:aws_access_key_id]
      @aws_secret_access_key = options[:aws_secret_access_key]
      @aws_region = options[:aws_region]
      @aws_endpoint = options[:aws_endpoint]
    end

    # Call with a SitemapLocation and string data
    def write(location, raw_data)
      SitemapGenerator::FileAdapter.new.write(location, raw_data)
      s3_object = s3_resource.bucket(@bucket).object(location.path_in_public)
      s3_object.upload_file(location.path,
        acl: 'public-read',
        cache_control: 'private, max-age=0, no-cache',
        content_type: location[:compress] ? 'application/x-gzip' : 'application/xml'
      )
    end

    private

    def s3_resource
      @s3_resource ||= Aws::S3::Resource.new(s3_resource_options)
    end

    def s3_resource_options
      options = {}
      options[:region] = @aws_region if !@aws_region.nil?
      options[:endpoint] = @aws_endpoint if !@aws_endpoint.nil?
      if !@aws_access_key_id.nil? && !@aws_secret_access_key.nil?
        options[:credentials] = Aws::Credentials.new(
          @aws_access_key_id,
          @aws_secret_access_key
        )
      end
      options
    end
  end
end
