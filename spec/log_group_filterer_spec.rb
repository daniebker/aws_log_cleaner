require 'aws_log_cleaner'
require_relative 'builders/log_group_builder'
require_relative 'builders/api_gateway_builder'

RSpec.describe AwsLogCleaner::LogGroupFilterer do

  let(:cloud_watch_logs) { instance_double('AwsLogCleaner::CloudWatchLogs') }
  let(:log_group_filterer) {
    AwsLogCleaner::LogGroupFilterer.new(cloud_watch_logs)
  }

  it 'should return a list of log groups that contain the text' do
    log_groups = LogGroupBuilder.a_list_of_log_groups_with_text(
      'some_text', 3
    )
    log_groups.push(LogGroupBuilder.a_log_group_with_name('some_other_log_group'))

    allow(cloud_watch_logs)
      .to receive(:list_all_log_groups)
      .and_return(log_groups)

    expect(log_group_filterer.filter_by_name_includes('some_text'))
      .to match_array(log_groups.take(3))
  end

  it 'should ignore casing in the log group name' do
    log_groups = []
    log_groups.push(LogGroupBuilder.a_log_group_with_name('some_log_group'))
    log_groups.push(LogGroupBuilder.a_log_group_with_name('soME_log_group'))
    log_groups.push(LogGroupBuilder.a_log_group_with_name('SOME_log_group'))
    log_groups.push(LogGroupBuilder.a_log_group_with_name('some_other_log_group'))

    allow(cloud_watch_logs)
      .to receive(:list_all_log_groups)
      .and_return(log_groups)

    expect(log_group_filterer.filter_by_name_includes('some_log'))
      .to match_array(log_groups.take(3))
  end

end
