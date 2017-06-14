require 'aws-sdk'

Aws.use_bundled_cert!

module AwsLogCleaner

  # wrapper for aws credentials
  class AwsCredentials

    attr_reader :credentials, :region

    def initialize(access_key = nil, secret = nil, region = nil)
      key_id = access_key || ENV['AWS_ACCESS_KEY_ID']
      secret = secret || ENV['AWS_SECRET_ACCESS_KEY']
      @region = region || ENV['AWS_DEFAULT_REGION']

      @credentials =
        if key_id.nil? && secret.nil?
          Aws::SharedCredentials.new
        else
          Aws::Credentials.new(key_id, secret)
        end
    end
  end
end
