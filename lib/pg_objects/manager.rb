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
class PgObjects::Manager
  include Import['db_object_factory', 'config', 'logger']

  ##
  # event: +:before+ or +:after+
  #
  # used to reference configuration settings +before_path+ and +after_path+
  def load_files(event)
    validate_workability

    dir = config.send "#{event}_path"
    Dir[File.join(dir, '**', "*.{#{config.extensions.join(',')}}")].each do |path|
      objects << db_object_factory.create_instance(path)
    end

    self
  end

  def create_objects
    objects.each { create_object(_1) }
  end

  def objects
    @objects ||= []
  end

  private

  def validate_workability
    raise PgObjects::UnsupportedAdapterError if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'
  end

  def create_object(obj)
    return if obj.status == :done
    raise PgObjects::CyclicDependencyError, obj.name if obj.status == :processing

    obj.status = :processing

    create_dependencies(obj.dependencies)

    logger.write("creating #{obj.name}")
    ActiveRecord::Base.connection.execute(obj.sql_query)

    obj.status = :done
  end

  def create_dependencies(dependencies)
    dependencies.each { |dep_name| create_object(find_object(dep_name)) }
  end

  def find_object(dep_name)
    result = objects.select { |obj| [obj.name, obj.full_name, obj.object_name].compact.include? dep_name }

    raise PgObjects::AmbiguousDependencyError, dep_name if result.size > 1
    raise PgObjects::DependencyNotExistError, dep_name if result.empty?

    result[0]
  end
end
