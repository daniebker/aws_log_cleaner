require 'aws-sdk'

Aws.use_bundled_cert!

# Helper class to build log groups.
class LogGroupBuilder

  def self.a_log_group_with_name(name)
    log_group = Aws::CloudWatchLogs::Types::LogGroup.new
    log_group.log_group_name = name
    log_group
  end

  def self.a_list_of_log_groups_with_text(text, amount)
    (1..amount).map do |i|
      a_log_group_with_name("/aws/lambda/#{text}_#{i}")
    end
  end
end