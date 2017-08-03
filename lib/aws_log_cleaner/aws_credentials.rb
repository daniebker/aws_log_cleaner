require 'aws-sdk'

Aws.use_bundled_cert!

module AwsLogCleaner

  # wrapper for aws credentials
  class AwsCredentials

    attr_reader :credentials, :region

    def initialize(credential_args = nil)
      
      if credential_args.nil?
        key_id  = ENV['AWS_ACCESS_KEY_ID']
        secret  = ENV['AWS_SECRET_ACCESS_KEY']
        @region = ENV['AWS_DEFAULT_REGION']
      else
        if credential_args[:profile] \
          && (credential_args[:access_key] || credential_args[:secret] )
          raise "Cannot pass a profile and a secret"
        end

        if credential_args[:profile]
          profile = credential_args[:profile]
        else
          key_id = credential_args[:access_key]
          secret = credential_args[:secret]
        end        
        @region = credential_args[:region] || ENV['AWS_DEFAULT_REGION']
      end

      @credentials =
        if key_id.nil? && secret.nil?
          begin
            profile.nil? ? Aws::SharedCredentials.new : Aws::SharedCredentials.new(profile_name: profile)
          rescue Aws::Errors::NoSuchProfileError
            raise_credentials_error
          end
        else
          Aws::Credentials.new(key_id, secret)
        end

        if @credentials.nil? || @region.nil?
          raise_credentials_error
        end

        return @credentials
    end

    private

    def raise_credentials_error
      raise "Could not load credentials."
    end
    
  end
end
