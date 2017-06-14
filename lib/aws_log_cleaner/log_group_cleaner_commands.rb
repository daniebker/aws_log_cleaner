require_relative 'cloud_watch_logs'

module AwsLogCleaner

  # Responsible for cleaning log groups in AWS.
  class LogGroupCleanerCommands

    def initialize(cloud_watch_logs, api_retriever, log_group_filterer)
      @cloud_watch_logs = cloud_watch_logs
      @api_retriever = api_retriever
      @log_group_filterer = log_group_filterer
    end

    def plan(text)
      result(text)
    end

    def delete(text)
      @cloud_watch_logs.delete_log_groups(log_group_names_containing(text))
      result(text)
    end

    private

    def log_group_names_containing(text)
      if @log_group_names.nil?
        @log_group_names = []
        log_groups =
          @log_group_filterer.filter_by_name_includes(text)

        apis = @api_retriever.retrieve(text)
        apis.each do |api|
          log_groups.concat(
            @log_group_filterer.filter_by_name_includes(api.id.to_s)
          )
        end

        log_groups.each do |log_group|
          @log_group_names.push(log_group.log_group_name)
        end
      end

      @log_group_names
    end

    def result(text)
      to_delete = []
      log_group_names_containing(text).each do |name|
        to_delete.push("(-) #{name}")
      end
      to_delete
    end

  end

end
