require_relative 'aws_log_cleaner/cloud_watch_logs'
require_relative 'aws_log_cleaner/log_group_cleaner'
require_relative 'aws_log_cleaner/api_gateway'
require_relative 'aws_log_cleaner/api_gateway_retriever'
require_relative 'aws_log_cleaner/log_group_filterer'
require_relative 'aws_log_cleaner/aws_credentials'
require_relative 'aws_log_cleaner/version'

module AwsLogCleaner
  class AwsLogCleaner
    def initialize(credentials_args, like, clean_orphans)
      credentials = AwsCredentials.new(credentials_args)
      cloud_watch_logs = CloudWatchLogs.new(credentials)
      api_gateway = ApiGateway.new(credentials)

      api_retriever = ApiGatewayRetriever.new(api_gateway)
      log_group_filterer = LogGroupFilterer.new(cloud_watch_logs)

      @log_cleaner = LogGroupCleaner.new(
        cloud_watch_logs,
        api_retriever,
        log_group_filterer,
        like,
        clean_orphans
      )
    end

    def plan
      @log_cleaner.plan
    end

    def delete
      @log_cleaner.delete
    end
  end
end
