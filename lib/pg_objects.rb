require 'pg_objects/version'
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
require 'pg_objects/parsed_object/base'
require 'pg_objects/parsed_object/aggregate'
require 'pg_objects/parsed_object/conversion'
require 'pg_objects/parsed_object/event_trigger'
require 'pg_objects/parsed_object/function'
require 'pg_objects/parsed_object/materialized_view'
require 'pg_objects/parsed_object/operator'
require 'pg_objects/parsed_object/operator_class'
require 'pg_objects/parsed_object/table'
require 'pg_objects/parsed_object/text_search_parser'
require 'pg_objects/parsed_object/text_search_template'
require 'pg_objects/parsed_object/trigger'
require 'pg_objects/parsed_object/type'
require 'pg_objects/parsed_object/view'
require 'pg_objects/parsed_object_factory'
require 'pg_objects/parser'

module PgObjects
  AmbiguousDependencyError = Class.new(StandardError)
  CyclicDependencyError = Class.new(StandardError)
  DependencyNotExistError = Class.new(StandardError)
  UnsupportedAdapterError = Class.new(StandardError)
end
