require 'aws-sdk-cloudwatchlogs'

Aws.use_bundled_cert!

class LogGroupBuilder
  def self.a_log_group_with_name(name)
    log_group = Aws::CloudWatchLogs::Types::LogGroup.new
    log_group.log_group_name = name
    log_group
  end

  def self.a_list_of_log_groups_with_text(text, amount)
    (1..amount).map do |i|
      a_log_group_with_name("#{text}_#{i}")
    end
  end
end
