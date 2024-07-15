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
bundle install
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

Store DB objects as CREATE (or CREATE OR UPDATE) queries in files within a directory structure (default: *db/objects*).

You can control the order of creation by using the directive *depends_on* in an SQL comment:

```sql
--!depends_on my_another_func
CREATE FUNCTION my_func()
...
```

The string after the directive should be the name of the file that the dependency refers to, without the file extension.

## Configuration

You have the option to configure the gem using either a YAML file or a Ruby initializer. The priority order for configuration is as follows:
1. Ruby initializer
2. YAML config
3. Default values

### YAML

Create `pg_objects.yml` in the application *config* directory:

```yaml
# pg_objects.yml

# Specify the directories where the DB objects files are located
directories:
  before: path/to/objects/before # executed before the migrations
  after: path/to/objects/after # executed after the migrations

# Specify the file extensions of the DB objects files
extensions:
  - sql
  - txt

# Specify whether to suppress output to console
silent: false
```

### Initializer

Create file in *config/initializers* directory with the following content:

```ruby
PgObjects.configure do |config|
  config.before_path = 'path/to/objects/before' # default: 'db/objects/before'
  config.after_path = 'path/to/objects/after' # default: 'db/objects/after'
  config.extensions = ['sql', 'txt'] # default: 'sql'
  config.silent = true # whether to suppress output to console, default: false
end
```

Otherwise, the default values will be used.

Please make sure to verify that the specified directories actually exist.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marinazzio/pg_objects.
