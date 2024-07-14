require 'bundler/setup'
require 'active_record'
require 'byebug'
require 'faker'
require 'pg_objects'
require 'rspec-parameterized'

require 'dry/configurable/test_interface'

require 'support/fixture_helpers'
require 'support/source_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  include FixtureHelpers
  include SourceHelpers

  config.before(:suite) do
    create_fixtures(:before)
    create_fixtures(:after)
  end

  config.after(:suite) do
    clean_fixtures
  end
end

class PgObjects::Config
  enable_test_interface
end
