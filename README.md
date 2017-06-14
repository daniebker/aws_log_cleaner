# AwsLogCleaner

A gem to clean up aws lambda and Api Gateway log groups that contain a search term.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aws_log_cleaner'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aws_log_cleaner

## Usage

### Requirements

* `AWS_SECRET_KEY` & `AWS_ACCESS_KEY` env variables must be set.  
OR
* A credentials file must be present in  `~\.aws`

The application defaults to `eu-west-1` but this can be overridden using `AWS_DEFAULT_REGION` environment variable.

### From the command line

* Get help by using:

`aws_log_cleaner -h`

* Run the plan command in eu-west-1 where prefix like channel.

`aws_log_cleaner -p -l 'some_text'`

## Code 

Initialise a new LogCleaner 

`log_cleaner = AwsLogCleaner::AwsLogCleaner.new`

Run a plan

`log_cleaner.plan('some_text')`

Or run a delete 

`log_cleaner.delete('some_text')`

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).