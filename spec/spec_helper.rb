require 'bundler/setup'
require 'active_record'
require 'byebug'
require 'pg_objects'

require 'support/fixture_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  include FixtureHelpers

  config.before(:suite) do
    create_fixtures
  end

  config.after(:suite) do
    clean_fixtures
  end
end
