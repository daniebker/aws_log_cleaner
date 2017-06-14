require_relative 'aws_log_cleaner/cloud_watch_logs'
require_relative 'aws_log_cleaner/log_group_cleaner_commands'
require_relative 'aws_log_cleaner/api_gateway'
require_relative 'aws_log_cleaner/api_gateway_retriever'
require_relative 'aws_log_cleaner/log_group_filterer'
require_relative 'aws_log_cleaner/aws_credentials'
require_relative 'aws_log_cleaner/version'


module AwsLogCleaner

  # Application wrapper
  class AwsLogCleaner

    def initialize(access_key = nil, secret = nil, region = nil)
      credentials = AwsCredentials.new(access_key, secret, region)
      cloud_watch_logs = CloudWatchLogs.new(credentials)
      api_gateway = ApiGateway.new(credentials)

      api_retriever = ApiGatewayRetriever.new(api_gateway)
      log_group_filterer = LogGroupFilterer.new(cloud_watch_logs)

      @log_cleaner = LogGroupCleanerCommands.new(
        cloud_watch_logs,
        api_retriever,
        log_group_filterer
      )
    end

    def plan(like)
      @log_cleaner.plan(like)
    end

    def delete(like)
      @log_cleaner.delete(like)
    end

  end
end