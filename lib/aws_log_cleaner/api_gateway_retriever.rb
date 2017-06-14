
module AwsLogCleaner

  # Responsible for retrieving API gateway instances filtered by prefix
  class ApiGatewayRetriever

    def initialize(api_gateway)
      @api_gateway = api_gateway
    end

    def retrieve(prefix)
      apis = @api_gateway.list_all_apis
      apis.select{ |item| item.name.to_s.downcase.start_with?(prefix) }
    end

  end
end
