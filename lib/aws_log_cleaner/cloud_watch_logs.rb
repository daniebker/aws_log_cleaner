require 'aws-sdk'

module AwsLogCleaner

  # Class responsible for interacting with AWS Cloudwatch
  class CloudWatchLogs

    # Required for Windows users.
    Aws.use_bundled_cert!

    def initialize(credentials)
      @cloud_watch_logs = Aws::CloudWatchLogs::Client.new(
        region: credentials.region,
        credentials: credentials.credentials
      )
    end

    def list_all_log_groups(token = nil)
      log_groups = []
      resp = describe_log_groups(token)
      log_groups.concat(resp.log_groups)

      if resp.next_token.to_s.empty?
        log_groups
      else
        log_groups.concat(
            list_all_log_groups(resp.next_token)
        )
      end
    end

    def delete_log_groups(log_group_names)
      log_group_names.each do |name|
        @cloud_watch_logs.delete_log_group(
          log_group_name: name
        )
      end
    end

    private

    def describe_log_groups(token)
      if token.nil?
        @cloud_watch_logs.describe_log_groups
      else
        @cloud_watch_logs.describe_log_groups(
          next_token: token
        )
      end
    end

  end
end
