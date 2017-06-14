require 'aws_log_cleaner'
require_relative 'builders/log_group_builder'
require_relative 'builders/api_gateway_builder'

RSpec.describe AwsLogCleaner::LogGroupCleanerCommands do

  EXPECTED_TOTAL_LOG_GROUPS = 6


  let(:cloud_watch_logs) { instance_double('AwsLogCleaner::CloudWatchLogs') }
  let(:api_retriever) { instance_double('AwsLogCleaner::ApiGatewayRetriever') }
  let(:log_group_filterer) { instance_double('AwsLogCleaner::LogGroupFilterer') }
  let(:log_group_cleaner_commands) {
    AwsLogCleaner::LogGroupCleanerCommands.new(
      cloud_watch_logs,
      api_retriever,
      log_group_filterer
    )}


  before(:each) do
    set_up_api_retriever
    set_up_log_group_filterer
  end

  context 'with no log groups found with text' do
    it 'returns empty array for plan' do
      expect(log_group_filterer).to receive(:filter_by_name_includes).once

      result = log_group_cleaner_commands.plan('some_other_text')

      expect(result.count).to eql(0)
    end

    it 'returns empty array for delete' do
      allow(cloud_watch_logs)
        .to receive(:delete_log_groups)
        .with([])

      result = log_group_cleaner_commands.delete('some_other_text')

      expect(result.count).to eql(0)
    end
  end

  context 'with log groups found for text' do
    it 'returns a list of items for plan' do

      expect_filter_called_for_lambda_and_api_gateway

      result = log_group_cleaner_commands.plan('some_text')

      expect(result.count).to eql(EXPECTED_TOTAL_LOG_GROUPS)
    end

    it 'returns a list of deleted items for delete' do
      allow(cloud_watch_logs)
        .to receive(:delete_log_groups)
        .with(%w(
          /aws/lambda/some_text_1
          /aws/lambda/some_text_2
          /aws/lambda/some_text_3
          api-gateway-1
          api-gateway-2
          api-gateway-3
        ))

      expect_filter_called_for_lambda_and_api_gateway

      result = log_group_cleaner_commands.delete('some_text')

      expect(result.count).to eql(EXPECTED_TOTAL_LOG_GROUPS)
    end
  end

  def set_up_api_retriever
    allow(api_retriever)
      .to receive(:retrieve)
      .with('some_other_text')
      .and_return([])

    apis = ApiGatewayBuilder.a_list_of_api_gateways_with_text('some_text', 3)

    allow(api_retriever)
      .to receive(:retrieve)
      .with('some_text')
      .and_return(apis)
  end

  def set_up_log_group_filterer
    log_groups = LogGroupBuilder.a_list_of_log_groups_with_text(
      'some_text', 3
    )

    log_group_filterer_filter_with_returns('some_other_text', [])
    log_group_filterer_filter_with_returns('some_text', log_groups)
    log_group_filterer_filter_with_returns(
      '1', [LogGroupBuilder.a_log_group_with_name('api-gateway-1')]
    )
    log_group_filterer_filter_with_returns(
      '2', [LogGroupBuilder.a_log_group_with_name('api-gateway-2')]
    )
    log_group_filterer_filter_with_returns(
      '3', [LogGroupBuilder.a_log_group_with_name('api-gateway-3')]
    )
  end

  def log_group_filterer_filter_with_returns(with, return_value)
    allow(log_group_filterer)
      .to receive(:filter_by_name_includes)
      .with(with)
      .and_return(return_value)
  end

  def expect_filter_called_for_lambda_and_api_gateway
    expect(log_group_filterer).to receive(:filter_by_name_includes).with('some_text')
    expect(log_group_filterer).to receive(:filter_by_name_includes).with('1')
    expect(log_group_filterer).to receive(:filter_by_name_includes).with('2')
    expect(log_group_filterer).to receive(:filter_by_name_includes).with('3')
  end
end
