require_relative 'pg_objects/version'

module PgObjects
  class AmbiguousDependencyError < StandardError; end

  # Raised when object dependencies form a cycle. Carries the resolution chain
  # that closed the cycle (e.g. ["a", "b", "a"]) via +cycle_path+; the message
  # renders it as "a -> b -> a". Also accepts a single name for compatibility.
  class CyclicDependencyError < StandardError
    attr_reader :cycle_path

    def initialize(cycle_path = nil)
      @cycle_path = Array(cycle_path)
      @cycle_path.empty? ? super() : super(@cycle_path.join(' -> '))
    end
  end

  class DependencyNotExistError < StandardError; end
  class UnsupportedAdapterError < StandardError; end
  class UnknownObjectTypeError < StandardError; end
  class MalformedStatementError < StandardError; end
end

require 'pg_objects/railtie' if defined?(Rails)

require 'dry-configurable'
require 'dry-container'
require 'dry-auto_inject'
require 'memery'

require 'pg_objects/container'
require 'pg_objects/config'
require 'pg_objects/db_object'
require 'pg_objects/db_object_factory'
require 'pg_objects/logger'
require 'pg_objects/manager'
require 'pg_objects/parsed_object'
require 'pg_objects/parser'
