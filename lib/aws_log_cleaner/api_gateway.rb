require 'aws-sdk-apigateway'

Aws.use_bundled_cert!

module AwsLogCleaner
  # Class responsible for interacting with the AWS ApiGatewayClient
  class ApiGateway
    def initialize(credentials)
      @api_client = Aws::APIGateway::Client.new(
        region: credentials.region,
        credentials: credentials.credentials
      )
    end

    def list_all_apis
      @rest_apis = get_rest_apis if @rest_apis.nil?
      @rest_apis
    end

    private

    def get_rest_apis
      Enumerator.new do |enum|
        request = { limit: 25 }
        loop do
          response = @api_client.get_rest_apis(request)
          response.items.each do |item|
            enum.yield item
          end
          break if response.position.nil?
          request[:position] = response.position
        end
      end
    end
  end
end
