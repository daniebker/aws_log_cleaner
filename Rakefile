
require 'bundler/gem_tasks'

require_relative 'lib/aws_log_cleaner'

task default: :spec

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end
