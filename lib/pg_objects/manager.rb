module PgObjects
  class Manager
    attr_reader :objects, :config, :log

    def initialize
      raise UnsupportedAdapterError if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'

      @objects = []
      @config = PgObjects.config
      @log = Logger.new(config.silent)
    end

    def load_files(event)
      dir = config.send "#{event}_path"
      Dir[File.join(dir, '**', "*.{#{config.extensions.join(',')}}")].each do |path|
        @objects << PgObjects::DbObject.new(path)
      end

      self
    end

    def create_objects
      @objects.each { |obj| create_object obj }
    end

    private

    def create_object(obj)
      return if obj.status == :done
      raise CyclicDependencyError, obj.name if obj.status == :processing

      obj.status = :processing

      create_dependencies(obj.dependencies)

      log.write("creating #{obj.name}")
      ActiveRecord::Base.connection.exec_query obj.sql_query

      obj.status = :done
    end

    def create_dependencies(dependencies)
      dependencies.each { |dep_name| create_object find_object(dep_name) }
    end

    def find_object(dep_name)
      result = @objects.select { |obj| obj.name == dep_name }

      raise AmbiguousDependencyError, dep_name if result.size > 1
      raise DependencyNotExistError, dep_name if result.empty?

      result[0]
    end
  end
end
