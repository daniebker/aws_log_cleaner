
RSpec.describe AwsLogCleaner::AwsCredentials do

  let(:constructor_access_key) { 'constructor access key' }
  let(:constructor_secret) { 'constructor secret' }
  let(:constructor_region) { 'constructor region' }
  let(:environment_access_key) { 'environment access key' }
  let(:environment_secret) { 'environment secret' }
  let(:environment_region) { 'environment region' }

  before(:each) do
    ENV['AWS_ACCESS_KEY_ID'] = environment_access_key
    ENV['AWS_SECRET_ACCESS_KEY'] = environment_secret
    ENV['AWS_DEFAULT_REGION'] = environment_region
  end

  it 'should use input credentials as priority' do
    aws_credentials = AwsLogCleaner::AwsCredentials.new(
      constructor_access_key,
      constructor_secret,
      constructor_region
    )

    expect(aws_credentials.credentials.access_key_id)
      .to eql(constructor_access_key)
    expect(aws_credentials.credentials.secret_access_key)
      .to eql(constructor_secret)
    expect(aws_credentials.region)
      .to eql(constructor_region)
  end

  it 'should use environment variables credentials as secondary' do
    aws_credentials = AwsLogCleaner::AwsCredentials.new

    expect(aws_credentials.credentials.access_key_id)
      .to eql(environment_access_key)
    expect(aws_credentials.credentials.secret_access_key)
      .to eql(environment_secret)
    expect(aws_credentials.region)
      .to eql(environment_region)
  end
end
