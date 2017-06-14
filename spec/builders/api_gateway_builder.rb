require 'aws-sdk'

Aws.use_bundled_cert!

# Helper class to build log groups.
class ApiGatewayBuilder

  def self.an_api_with_name(name, id)
    api = Aws::APIGateway::Types::RestApi.new
    api.name = name
    api.id = id
    api
  end

  def self.a_list_of_api_gateways_with_text(text, amount)
    (1..amount).map do |i|
      an_api_with_name("#{text}_#{i}", i)
    end
  end

end
