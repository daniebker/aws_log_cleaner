require_relative 'cloud_watch_logs'

module AwsLogCleaner
  class LogGroupCleaner
    API_GATEWAY_LOG_PREFIX = 'API-Gateway-Execution-Logs_'.freeze

    def initialize(
      cloud_watch_logs,
      api_retriever,
      log_group_filterer,
      like,
      clean_orphans
    )
      @cloud_watch_logs = cloud_watch_logs
      @api_retriever = api_retriever
      @log_group_filterer = log_group_filterer
      @like = like.downcase unless like.nil?
      @clean_orphans = clean_orphans
    end

    def plan
      result(log_groups_to_delete)
    end

    def delete
      log_groups = log_groups_to_delete
      @cloud_watch_logs.delete_log_groups(log_groups)
      result(log_groups)
    end

    private

    def log_groups_to_delete
      log_groups = []
      log_groups.concat(log_group_names_containing(@like)) if @like
      log_groups.concat(log_group_names_orphan) if @clean_orphans
      log_groups.uniq
    end

    def log_group_names_containing(text)
      log_groups = @log_group_filterer.filter_by_name_includes(text)

      apis = @api_retriever.retrieve(text)
      apis.each do |api|
        log_groups.concat(
          @log_group_filterer.filter_by_name_includes(
            "#{API_GATEWAY_LOG_PREFIX}#{api.id}"
          )
        )
      end

      log_groups.map(&:log_group_name)
    end

    def log_group_names_orphan
      groups = @cloud_watch_logs.list_all_log_groups
      groups = groups.select { |log_group| orphan?(log_group) }
      groups.map(&:log_group_name)
    end

    def orphan?(log_group)
      apis = @api_retriever.retrieve_all
      api_id = extract_api_id(log_group.log_group_name)
      api_id.nil? ? false : apis.none? { |api| api.id == api_id }
    end

    def extract_api_id(log_group_name)
      match = log_group_name.match(%r{#{API_GATEWAY_LOG_PREFIX}(\w+)/\w+})
      match.captures[0] unless match.nil?
    end

    def result(log_groups)
      to_delete = []
      log_groups.each do |name|
        to_delete.push("(-) #{name}")
      end
      to_delete
    end
  end
end
