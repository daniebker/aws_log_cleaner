# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws_log_cleaner/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws_log_cleaner'
  spec.version       = AwsLogCleaner::VERSION
  spec.authors       = ['dbaker']
  spec.email         = ['dbaker@vistaprint.com']
  spec.summary       = 'Clean up lambda and API Gateway logs in AWS that contain a search term ' \
                          'in their log group name.'
  spec.description   = 'Cleans all logs in AWS that contain a search term in the log group name. ' \
                          'Also searches for api gateway instances that contain the search term ' \
                          'and finds their corresponding logs.'
  spec.homepage      = 'https://github.com/daniebker/aws_log_cleaner'
  spec.license       = 'Apache-2.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables << 'aws_log_cleaner'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.6.0'

  spec.add_dependency 'aws-sdk', '~> 3'
  spec.add_dependency 'colorize', '~> 0.8.1'
end
