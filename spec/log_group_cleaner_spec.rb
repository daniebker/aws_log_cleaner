require 'aws_log_cleaner'
require_relative 'builders/log_group_builder'
require_relative 'builders/api_gateway_builder'

RSpec.describe AwsLogCleaner::LogGroupCleaner do
  EXPECTED_MATCHING_LOG_GROUPS = 6
  EXPECTED_ORPHAN_LOG_GROUPS = 4

  let(:api_prefix) { AwsLogCleaner::LogGroupCleaner::API_GATEWAY_LOG_PREFIX }

  let(:cloud_watch_logs) { instance_double('AwsLogCleaner::CloudWatchLogs') }
  let(:api_retriever) { instance_double('AwsLogCleaner::ApiGatewayRetriever') }
  let(:log_group_filterer) { instance_double('AwsLogCleaner::LogGroupFilterer') }

  let(:matching_text) { 'matching_text'.freeze }
  let(:non_matching_text) { 'non_matching_text'.freeze }
  let(:another_text) { 'another_text'.freeze }

  let(:apis) do
    [ApiGatewayBuilder.an_api_with_name("#{matching_text}_1", '1'),
     ApiGatewayBuilder.an_api_with_name("#{matching_text}_2", '2'),
     ApiGatewayBuilder.an_api_with_name(another_text, '3')]
  end

  let(:log_groups) do
    [LogGroupBuilder.a_log_group_with_name("#{matching_text}1"),
     LogGroupBuilder.a_log_group_with_name("#{matching_text}2"),
     LogGroupBuilder.a_log_group_with_name("#{another_text}1"),
     LogGroupBuilder.a_log_group_with_name("#{another_text}2"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}1/Prod"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}1/Test"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}2/Prod"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}2/Test"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}3/Prod"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}3/Test"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}4_orphan/Prod"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}4_orphan/Test"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}5_orphan/Prod"),
     LogGroupBuilder.a_log_group_with_name("#{api_prefix}5_orphan/Test")]
  end

  before(:each) do
    set_up_cloud_watch_logs
    set_up_api_retriever
    set_up_log_group_filterer
  end

  describe '#plan' do
    context 'cleaning orphans disabled' do
      let(:clean_orphans) { false }

      context 'with no text specified' do
        it 'returns no log groups' do
          result = create_log_group_cleaner(nil).plan
          expect(result.count).to eql(0)
        end
      end

      context 'with no log groups matching text' do
        it 'does not return non matching log groups' do
          result = create_log_group_cleaner(non_matching_text).plan
          expect(result.count).to eql(0)
        end
      end

      context 'with log groups matching text' do
        it 'returns matching log groups' do
          result = create_log_group_cleaner(matching_text).plan
          expect(result.count).to eql(EXPECTED_MATCHING_LOG_GROUPS)
        end
      end
    end

    context 'cleaning orphans enabled' do
      let(:clean_orphans) { true }

      context 'with no text specified' do
        it 'returns orphan log groups' do
          result = create_log_group_cleaner(nil).plan
          expect(result.count).to eql(EXPECTED_ORPHAN_LOG_GROUPS)
        end
      end

      context 'with no log groups matching text' do
        it 'returns orphan log groups' do
          result = create_log_group_cleaner(non_matching_text).plan
          expect(result.count).to eql(EXPECTED_ORPHAN_LOG_GROUPS)
        end
      end

      context 'with log groups matching text' do
        it 'returns matching and orphan log groups' do
          result = create_log_group_cleaner(matching_text).plan
          expect(result.count).to eql(
            EXPECTED_MATCHING_LOG_GROUPS + EXPECTED_ORPHAN_LOG_GROUPS
          )
        end
      end
    end
  end

  describe '#delete' do
    context 'cleaning orphans disabled' do
      let(:clean_orphans) { false }

      context 'with no text specified' do
        it 'does not delete any log groups' do
          expect(cloud_watch_logs)
            .to receive(:delete_log_groups)
            .with([])

          result = create_log_group_cleaner(nil).delete
          expect(result.count).to eql(0)
        end
      end

      context 'with no log groups matching text' do
        it 'does not delete any log groups' do
          expect(cloud_watch_logs)
            .to receive(:delete_log_groups)
            .with([])

          result = create_log_group_cleaner(non_matching_text).delete
          expect(result.count).to eql(0)
        end
      end

      context 'with log groups matching text' do
        it 'deletes matching log groups' do
          expect(cloud_watch_logs)
            .to receive(:delete_log_groups)
            .with(["#{matching_text}1",
                   "#{matching_text}2",
                   "#{api_prefix}1/Prod",
                   "#{api_prefix}1/Test",
                   "#{api_prefix}2/Prod",
                   "#{api_prefix}2/Test"])

          result = create_log_group_cleaner(matching_text).delete
          expect(result.count).to eql(EXPECTED_MATCHING_LOG_GROUPS)
        end
      end
    end

    context 'cleaning orphans enabled' do
      let(:clean_orphans) { true }

      context 'with no text specified' do
        it 'deletes orphan log groups' do
          expect(cloud_watch_logs)
            .to receive(:delete_log_groups)
            .with(["#{api_prefix}4_orphan/Prod",
                   "#{api_prefix}4_orphan/Test",
                   "#{api_prefix}5_orphan/Prod",
                   "#{api_prefix}5_orphan/Test"])

          result = create_log_group_cleaner(nil).delete
          expect(result.count).to eql(EXPECTED_ORPHAN_LOG_GROUPS)
        end
      end

      context 'with no log groups matching text' do
        it 'does not delete any log groups' do
          expect(cloud_watch_logs)
            .to receive(:delete_log_groups)
            .with(["#{api_prefix}4_orphan/Prod",
                   "#{api_prefix}4_orphan/Test",
                   "#{api_prefix}5_orphan/Prod",
                   "#{api_prefix}5_orphan/Test"])

          result = create_log_group_cleaner(non_matching_text).delete
          expect(result.count).to eql(EXPECTED_ORPHAN_LOG_GROUPS)
        end
      end

      context 'with log groups matching text' do
        it 'deletes matching log groups' do
          expect(cloud_watch_logs)
            .to receive(:delete_log_groups)
            .with(["#{matching_text}1",
                   "#{matching_text}2",
                   "#{api_prefix}1/Prod",
                   "#{api_prefix}1/Test",
                   "#{api_prefix}2/Prod",
                   "#{api_prefix}2/Test",
                   "#{api_prefix}4_orphan/Prod",
                   "#{api_prefix}4_orphan/Test",
                   "#{api_prefix}5_orphan/Prod",
                   "#{api_prefix}5_orphan/Test"])

          result = create_log_group_cleaner(matching_text).delete
          expect(result.count).to eql(
            EXPECTED_MATCHING_LOG_GROUPS + EXPECTED_ORPHAN_LOG_GROUPS
          )
        end
      end
    end
  end

  def create_log_group_cleaner(like)
    AwsLogCleaner::LogGroupCleaner.new(
      cloud_watch_logs,
      api_retriever,
      log_group_filterer,
      like,
      clean_orphans
    )
  end

  def set_up_cloud_watch_logs
    allow(cloud_watch_logs)
      .to receive(:list_all_log_groups)
      .and_return(log_groups)
  end

  def set_up_api_retriever
    allow(api_retriever)
      .to receive(:retrieve)
      .with(non_matching_text)
      .and_return([])

    allow(api_retriever)
      .to receive(:retrieve)
      .with(matching_text)
      .and_return(apis.select { |api| api.name.include?(matching_text) })

    allow(api_retriever)
      .to receive(:retrieve_all)
      .and_return(apis)
  end

  def set_up_log_group_filterer
    log_group_filterer_filter_with_returns(non_matching_text, [])

    log_group_filterer_filter_with_returns(
      matching_text,
      log_groups.select { |group| group.log_group_name.include?(matching_text) }
    )

    apis.each do |api|
      log_group_filterer_filter_with_returns(
        "#{api_prefix}#{api.id}",
        [LogGroupBuilder.a_log_group_with_name("#{api_prefix}#{api.id}/Prod"),
         LogGroupBuilder.a_log_group_with_name("#{api_prefix}#{api.id}/Test")]
      )
    end
  end

  def log_group_filterer_filter_with_returns(with, return_value)
    allow(log_group_filterer)
      .to receive(:filter_by_name_includes)
      .with(with)
      .and_return(return_value)
  end
end
