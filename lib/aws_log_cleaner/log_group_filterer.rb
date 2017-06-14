
module AwsLogCleaner

  class LogGroupFilterer

    def initialize(cloud_watch_logs)
      @cloud_watch_logs = cloud_watch_logs
    end

    def filter_by_name_includes(text)
      log_groups = @cloud_watch_logs.list_all_log_groups
      log_groups.select{ |item| item.log_group_name.to_s.downcase.include?(text) }
    end

  end

end
