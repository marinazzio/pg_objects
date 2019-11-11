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

  spec.required_ruby_version = '>= 2.3.8'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/marinazzio/pg_objects/issues',
    'documentation_uri' => 'https://github.com/marinazzio/pg_objects/blob/master/README.md',
    'homepage_uri' => 'https://github.com/marinazzio/pg_objects',
    'source_code_uri' => 'https://github.com/marinazzio/pg_objects'
  }

  spec.post_install_message = <<-MSG
    To create initial directories structure run:

      $ bundle exec rails generate pg_objects:install

  MSG

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 4', '< 7'
  spec.add_dependency 'pg_query', '~> 1'
  spec.add_dependency 'railties', '>= 4', '< 7'
  spec.add_dependency 'rake-hooks', '~> 1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
