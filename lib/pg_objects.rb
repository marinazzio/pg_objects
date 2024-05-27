require 'pg_objects/version'
require 'pg_objects/railtie' if defined?(Rails)

require 'dry-configurable'
require 'dry-container'
require 'dry-auto_inject'
require 'dry/monads'
require 'memery'

require 'pg_objects/container'
require 'pg_objects/config'
require 'pg_objects/db_object'
require 'pg_objects/db_object_factory'
require 'pg_objects/logger'
require 'pg_objects/manager'
require 'pg_objects/parsed_object'
require 'pg_objects/parser'

module PgObjects
  AmbiguousDependencyError = Class.new(StandardError)
  CyclicDependencyError = Class.new(StandardError)
  DependencyNotExistError = Class.new(StandardError)
  UnsupportedAdapterError = Class.new(StandardError)
end
