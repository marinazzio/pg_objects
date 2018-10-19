require 'pg_objects/version'
require 'pg_objects/railtie' if defined?(Rails)

require 'pg_objects/config'
require 'pg_objects/db_object'
require 'pg_objects/logger'
require 'pg_objects/manager'
require 'pg_objects/parser'

module PgObjects
  AmbiguousDependencyError = Class.new(StandardError)
  CyclicDependencyError = Class.new(StandardError)
  DependencyNotExistError = Class.new(StandardError)
  UnsupportedAdapterError = Class.new(StandardError)
end
