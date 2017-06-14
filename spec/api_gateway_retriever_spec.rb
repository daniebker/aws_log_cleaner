require 'aws_log_cleaner'
require_relative 'builders/log_group_builder'
require_relative 'builders/api_gateway_builder'

RSpec.describe AwsLogCleaner::ApiGatewayRetriever do

  EXPECTED_RESULTS = 3

  let(:api_gateway) { instance_double('AwsLogCleaner::ApiGateway') }
  let(:api_retriever) { AwsLogCleaner::ApiGatewayRetriever.new(api_gateway) }

  it 'should return a list of api gateways that contain the text' do
    apis = ApiGatewayBuilder.a_list_of_api_gateways_with_text(
      'some_text',
      3
    )
    apis.push(ApiGatewayBuilder.an_api_with_name('some_other_text', 4))

    allow(api_gateway)
      .to receive(:list_all_apis)
      .and_return(apis)

    expect(api_retriever.retrieve('some_text'))
      .to match_array(apis.take(EXPECTED_RESULTS))
  end

  it 'should ignore the casing of the api name' do
    apis = []
    apis.push(ApiGatewayBuilder.an_api_with_name('some_text', 1))
    apis.push(ApiGatewayBuilder.an_api_with_name('sOMe_text', 2))
    apis.push(ApiGatewayBuilder.an_api_with_name('SOME_text', 3))
    apis.push(ApiGatewayBuilder.an_api_with_name('some_other_text', 4))

    allow(api_gateway)
      .to receive(:list_all_apis)
      .and_return(apis)

    expect(api_retriever.retrieve('some_text'))
      .to match_array(apis.take(EXPECTED_RESULTS))
  end
end
