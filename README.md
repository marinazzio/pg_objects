[![Gem Version](https://badge.fury.io/rb/pg_objects.svg)](https://badge.fury.io/rb/pg_objects)
[![Maintainability](https://api.codeclimate.com/v1/badges/935cd23d8f899b6d8057/maintainability)](https://codeclimate.com/github/marinazzio/pg_objects/maintainability)

# PgObjects

Simple manager for PostgreSQL objects like triggers and functions.

Inspired by https://github.com/neongrau/rails_db_objects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_objects'
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install pg_objects
```

Run the installation procedure to initialize directories structure and configuration file:

```shell
bundle exec rails generate pg_objects:install
```

## Usage

Put DB objects as CREATE (or CREATE OR UPDATE) queries in files to directory structure (default: *db/objects*).

You can control order of creating by using directive *depends_on* in SQL comment:

```sql
--!depends_on my_another_func
CREATE FUNCTION my_func()
...
```

The string after directive should be a name of file with dependency without extension.

## Configuration

Create file in *config/initializers* with the following content:

```ruby
PgObjects.configure do |config|
  config.directories = ['db/objects', 'another/path/to/files'] # default: 'db/objects'
  config.extensions = ['sql', 'txt'] # default: 'sql'
  config.silent = false # whether to suppress output to console
end
```

Otherwise default values will be used.

Remember, you take care the specified directories are exist.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marinazzio/pg_objects.
