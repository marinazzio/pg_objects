require_relative 'pg_objects/version'

module PgObjects
  class AmbiguousDependencyError < StandardError; end
  class CyclicDependencyError < StandardError; end
  class DependencyNotExistError < StandardError; end
  class UnsupportedAdapterError < StandardError; end
end

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
