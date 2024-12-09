lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_objects/version'

Gem::Specification.new do |spec|
  spec.name          = 'pg_objects'
  spec.version       = PgObjects::VERSION
  spec.authors       = ['Denis Kiselyov']
  spec.email         = ['denis.kiselyov@gmail.com']
  spec.license       = 'MIT'
  spec.summary       = %q(Simple manager for PostgreSQL objects like triggers and functions)
  spec.homepage      = 'https://github.com/marinazzio/pg_objects'

  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/marinazzio/pg_objects/issues',
    'documentation_uri' => 'https://github.com/marinazzio/pg_objects/blob/master/README.md',
    'homepage_uri' => 'https://github.com/marinazzio/pg_objects',
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => 'https://github.com/marinazzio/pg_objects'
  }

  spec.post_install_message = <<-MSG
    To create initial directories structure run:

      $ bundle exec rails generate pg_objects:install

  MSG

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 6.1.7.0', '< 8'
  spec.add_dependency 'dry-auto_inject', '~> 1'
  spec.add_dependency 'dry-configurable', '~> 1'
  spec.add_dependency 'dry-container', '0.11.0'
  spec.add_dependency 'dry-monads', '~> 1.6'
  spec.add_dependency 'memery', '>= 1.5', '< 1.7'
  spec.add_dependency 'pg_query', '>= 5', '< 7'
  spec.add_dependency 'railties', '>= 4', '< 8'
  spec.add_dependency 'rake-hooks', '~> 1'
end
