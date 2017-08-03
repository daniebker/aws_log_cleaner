
RSpec.describe AwsLogCleaner::AwsCredentials do

  let(:constructor_access_key) { 'constructor access key' }
  let(:constructor_secret) { 'constructor secret' }
  let(:constructor_region) { 'constructor region' }
  let(:environment_access_key) { 'environment access key' }
  let(:environment_secret) { 'environment secret' }
  let(:environment_region) { 'environment region' }
  let(:profile) { 'profile' }

  before(:each) do
    ENV['AWS_ACCESS_KEY_ID'] = environment_access_key
    ENV['AWS_SECRET_ACCESS_KEY'] = environment_secret
    ENV['AWS_DEFAULT_REGION'] = environment_region
  end

  it 'should use input credentials as priority' do
    aws_credentials = AwsLogCleaner::AwsCredentials.new(
      :access_key => constructor_access_key,
      :secret => constructor_secret,
      :region => constructor_region
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

  it "should use a profile over env variables" do
    expect { 
      AwsLogCleaner::AwsCredentials.new(
        :profile => profile
      )
    }.to raise_error(/Could not load credentials/)
  end

  it "should use a default profile as a last resort" do
    ENV['AWS_ACCESS_KEY_ID'] = nil
    ENV['AWS_SECRET_ACCESS_KEY'] = nil
  
    expect { 
      AwsLogCleaner::AwsCredentials.new
    }.to raise_error(/Could not load credentials/)
  end

  it "should throw an exception when a secret and a profile are passed" do
    expect { 
      aws_credentials = AwsLogCleaner::AwsCredentials.new(
        :access_key => constructor_access_key,
        :secret => constructor_secret,
        :region => constructor_region,
        :profile => profile
      )
    }.to raise_error("Cannot pass a profile and a secret")
  end
end
