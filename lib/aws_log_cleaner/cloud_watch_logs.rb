require 'aws-sdk-cloudwatchlogs'

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

    def list_all_log_groups
      @log_groups = describe_log_groups if @log_groups.nil?
      @log_groups
    end

    def delete_log_groups(log_group_names)
      log_group_names.each do |name|
        @cloud_watch_logs.delete_log_group(
          log_group_name: name
        )
      end
    end

    private

    def describe_log_groups
      log_groups = []
      token = nil
      loop do
        resp = @cloud_watch_logs.describe_log_groups(next_token: token)
        log_groups.concat(resp.log_groups)
        token = resp.next_token
        return log_groups if token.to_s.empty?
      end
    end
  end
end
