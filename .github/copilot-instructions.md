# PG Objects
PG Objects is a Ruby gem for managing PostgreSQL database objects like triggers and functions. It provides a simple manager that handles dependencies between database objects and integrates with Rails applications.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively
- Bootstrap, build, and test the repository:
  - `gem install --user-install bundler`
  - `export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"`
  - `bundle config set --local path 'vendor/bundle'`
  - `bundle install` -- takes 45-60 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
- `bundle exec rspec spec` -- takes 4 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
- `bundle exec rubocop` -- takes 3 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
- `bundle exec bundle-audit check` -- takes 2 seconds (first run downloads advisory database). NEVER CANCEL. Set timeout to 180+ seconds for first run.
- Performance benchmarking:
  - `bundle exec rake benchmark` -- takes 1 second. NEVER CANCEL. Set timeout to 30+ seconds.
- Interactive console:
  - `./bin/console` -- launches IRB with pg_objects loaded
- Install gem locally:
  - `bundle exec rake install` -- takes 9 seconds. NEVER CANCEL. Set timeout to 120+ seconds.

## Validation
- Always run through the complete test suite after making changes: `bundle exec rspec spec`
- ALWAYS run linting before completing work: `bundle exec rubocop`
- Always run bundle audit to check for security vulnerabilities: `bundle exec bundle-audit check`
- Test parsing functionality with sample SQL files to ensure changes work correctly
- NEVER CANCEL builds or tests - they complete quickly (under 60 seconds)

## Common Tasks
The following are outputs from frequently run commands. Reference them instead of viewing, searching, or running bash commands to save time.

### Repository Root Structure
```
.
├── .github/           # CI/CD workflows (ci.yml, bundle_audit.yml, publish.yml)
├── .rspec             # RSpec configuration
├── .rubocop.yml       # RuboCop linting configuration
├── bin/
│   ├── setup          # Setup script (runs bundle install)
│   ├── console        # Interactive console
│   └── benchmark      # Performance benchmark tool
├── lib/
│   ├── pg_objects.rb  # Main entry point
│   ├── pg_objects/    # Core library files
│   │   ├── config.rb
│   │   ├── manager.rb
│   │   ├── parser.rb
│   │   └── parsed_object/ # SQL object parsers
│   └── generators/pg_objects/install/ # Rails generator
├── spec/              # RSpec test files
├── Gemfile            # Gem dependencies
├── pg_objects.gemspec # Gem specification
├── Rakefile           # Rake tasks (spec, benchmark)
└── README.md          # Documentation
```

### Key Files and Directories
- **lib/pg_objects.rb**: Main entry point that requires all components
- **lib/pg_objects/manager.rb**: Core manager for database objects
- **lib/pg_objects/parser.rb**: SQL parsing and dependency extraction
- **lib/pg_objects/parsed_object/**: Specific parsers for different SQL object types
- **spec/**: Complete test suite with fixtures
- **bin/benchmark**: Performance benchmarking tool with detailed metrics
- **Gemfile**: Development and test dependencies (RSpec, RuboCop, etc.)

### Gemfile Dependencies
- **Runtime**: activerecord, dry-auto_inject, dry-configurable, pg_query, railties
- **Development/Test**: rspec, rubocop, bundler-audit, faker, pry-byebug

### Common Command Outputs
#### `bundle exec rspec spec` (Expected: ~4 seconds, 54 examples, 0 failures)
```
54 examples, 0 failures
Finished in 2.24 seconds
```

#### `bundle exec rubocop` (Expected: ~3 seconds, 60 files, no offenses)
```
60 files inspected, no offenses detected
```

#### `bundle exec bundle-audit check` (Expected: ~2 seconds after initial setup)
```
No vulnerabilities found
```

#### `bundle exec rake benchmark` (Expected: ~1 second)
```
PG Objects Performance Benchmark
==================================================
File I/O Performance: ~100,000+ files/s
Parsing Performance: ~7,000 files/s 
Full Workflow Performance: ~6,000 objects/s
Benchmark completed successfully!
```

## Development Workflow
1. Always run `bundle install` after cloning or changing dependencies
2. Make changes to code in lib/ directory
3. Add or update tests in spec/ directory for any changes
4. Run `bundle exec rspec spec` to ensure all tests pass
5. Run `bundle exec rubocop` to ensure code style compliance
6. Use `bundle exec rake benchmark` to test performance impact
7. Run `bundle exec bundle-audit check` for security validation

## Troubleshooting
- If bundler is not found: `gem install --user-install bundler && export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"`
- If bundle install fails with permission errors: `bundle config set --local path 'vendor/bundle'`
- Ruby version required: >= 3.2.0 (tested with 3.2, 3.3, 3.4)
- The gem requires PostgreSQL and uses pg_query for SQL parsing
- Dependencies include ActiveRecord, dry gems, and memery for caching

## Testing SQL Parsing
Create test SQL files with dependencies:
```sql
--!depends_on other_function
CREATE OR REPLACE FUNCTION my_function(param INTEGER)
RETURNS INTEGER AS $$
BEGIN
  RETURN param * 2;
END;
$$ LANGUAGE plpgsql;
```

Test parsing with:
```ruby
parser = PgObjects::Parser.new
content = File.read('path/to/file.sql')
object_name = parser.load(content).fetch_object_name
dependencies = parser.fetch_directives[:depends_on]
```