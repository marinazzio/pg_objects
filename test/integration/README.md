# Integration Tests

This directory contains integration tests for the `pg_objects` gem that test the complete workflow in a real Rails application environment.

## Test Structure

- `dummy_app/` - A minimal Rails application configured to use the `pg_objects` gem
- `spec/integration/dummy_app_integration_spec.rb` - RSpec integration tests

## What the Tests Cover

The integration tests validate:

1. **Generator Installation**: Tests that `rails generate pg_objects:install` creates the required directory structure (`db/objects/before` and `db/objects/after`)

2. **SQL Object Management**: 
   - Loading and creating SQL objects without dependencies
   - Handling dependencies between SQL objects using `--!depends_on` directives
   - Proper error handling for missing dependencies
   - Proper error handling for cyclic dependencies

3. **Configuration**: 
   - Custom configuration paths via Ruby initializer
   - Silent mode functionality

4. **Error Handling**: 
   - Validation that only PostgreSQL databases are supported
   - Proper error messages for various failure scenarios

5. **Object Type Parsing**: 
   - Correct identification of different SQL object types (functions, views, triggers)
   - Proper parsing using the `pg_query` gem

6. **Rake Task Integration**: 
   - Verification that the required Rake tasks are available
   - Integration with Rails migration hooks

## Running the Tests

From the gem root directory:

```bash
bundle exec rspec spec/integration/dummy_app_integration_spec.rb
```

Or run all tests including integration tests:

```bash
bundle exec rake spec
```

## Notes

- The tests use mocked database connections to avoid requiring an actual PostgreSQL database
- The dummy app is a minimal Rails 8 application with just the necessary configuration
- SQL files are created and cleaned up dynamically during test execution
- The tests focus on the gem's core functionality rather than actual database operations