require 'pg_objects/version'
require 'pg_objects/railtie' if defined?(Rails)

require 'pg_objects/config'
require 'pg_objects/db_object'
require 'pg_objects/manager'

module PgObjects
  UnsupportedAdapterError = Class.new(StandardError)
end
