##
# Manages process to create objects
#
# Usage:
#
#   Manager.new(config, logger).load_files(:before).create_objects
#
# or
#
#   Manager.new(config, logger).load_files(:after).create_objects
#
# Pass +connection:+ to run against a specific database connection instead of
# the global one (Rails 6+ multi-DB):
#
#   Manager.new(connection: AnimalsRecord.connection).load_files(:before).create_objects
class PgObjects::Manager
  include Import['db_object_factory', 'config', 'logger']

  def initialize(connection: nil, **deps)
    super(**deps)
    @connection = connection
  end

  ##
  # event: +:before+ or +:after+
  #
  # used to reference configuration settings +before_path+ and +after_path+
  #
  # Resets the object list before loading, so each call reflects only the
  # files for the given event.
  def load_files(event)
    validate_workability

    objects.clear
    dir = config.send "#{event}_path"
    Dir[File.join(dir, '**', "*.{#{config.extensions.join(',')}}")].each do |path|
      objects << db_object_factory.create_instance(path)
    end

    self
  end

  def create_objects
    build_objects_index
    within_transaction { objects.each { create_object(_1) } }
  end

  def objects
    @objects ||= []
  end

  private

  def connection
    @connection || ActiveRecord::Base.connection
  end

  def validate_workability
    raise PgObjects::UnsupportedAdapterError if connection.adapter_name != 'PostgreSQL'
  end

  def within_transaction(&)
    return yield unless config.transactional

    connection.transaction(&)
  end

  def create_object(obj)
    return if obj.status == :done
    raise PgObjects::CyclicDependencyError, obj.name if obj.status == :processing

    obj.status = :processing

    create_dependencies(obj.dependencies)

    logger.write("creating #{obj.name}")
    connection.execute(obj.sql_query)

    obj.status = :done
  end

  def create_dependencies(dependencies)
    dependencies.each { |dep_name| create_object(find_object(dep_name)) }
  end

  def build_objects_index
    @objects_index = objects.each_with_object({}) do |obj, index|
      [obj.name, obj.full_name, obj.object_name, obj.qualified_object_name].compact.uniq.each do |key|
        (index[key] ||= []) << obj
      end
    end
  end

  def find_object(dep_name)
    result = @objects_index[dep_name] || []

    raise PgObjects::AmbiguousDependencyError, dep_name if result.size > 1
    raise PgObjects::DependencyNotExistError, dep_name if result.empty?

    result[0]
  end
end
