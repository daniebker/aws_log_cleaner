
module AwsLogCleaner

  # Responsible for retrieving API gateway instances filtered by a given text
  class ApiGatewayRetriever

    def initialize(api_gateway)
      @api_gateway = api_gateway
    end

    def retrieve(text)
      apis = @api_gateway.list_all_apis
      apis.select{ |item| item.name.to_s.downcase.include?(text) }
    end

  end
end
