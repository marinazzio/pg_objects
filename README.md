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

### Performance Benchmarking

You can measure the performance of query parsing including file I/O operations using the included benchmark tool:

```shell
# Run the benchmark
bundle exec rake benchmark

# Or run directly
bundle exec bin/benchmark
```

The benchmark measures:

- **File I/O Performance**: Time to read SQL files from disk
- **SQL Parsing Performance**: Time to parse SQL queries using pg_query
- **Dependency Extraction Performance**: Time to extract `--!depends_on` directives from comments
- **Full Workflow Performance**: Combined time for file I/O, parsing, and dependency extraction
- **Memory Usage**: Memory consumption during the parsing process

The benchmark creates temporary SQL files of various sizes and complexities to provide realistic performance metrics. Results include throughput (files/objects per second) and average processing time per file.

Example output:
```
PG Objects Performance Benchmark
==================================================

File I/O Performance:
  Files processed: 59
  Time: 0.0005s
  Throughput: 108574.84 files/s

Parsing Performance:
  Files processed: 59
  Successful parses: 59
  Parse errors: 0
  Time: 0.0092s
  Throughput: 6411.8 files/s

Full Workflow Performance:
  Objects processed: 59
  Time: 0.0083s
  Throughput: 7105.78 objects/s
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marinazzio/pg_objects.
