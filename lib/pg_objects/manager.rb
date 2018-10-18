module PgObjects
  class Manager
    attr_reader :objects, :config

    def initialize
      raise UnsupportedAdapterError if ActiveRecord::Base.connection.adapter_name != 'PostgreSQL'

      @objects = []
      @config = PgObjects.config
    end

    def load_files
      config.directories.each do |dir|
        Dir[File.join(dir, '**', "*.{#{config.extensions.join(',')}}")].each do |path|
          @objects << PgObjects::DbObject.new(path)
        end
      end

      self
    end

    def create_objects
      @objects.each { |obj| create_object obj }
    end

    private

    def create_object(obj)
      return if obj.status == :done
      raise CyclicDependencyError if obj.status == :processing

      obj.status = :processing

      obj.dependencies.each { |dep_name| create_object find_object(dep_name) }
      ActiveRecord::Base.connection.exec_query obj.sql_query

      obj.status = :done
    end

    def find_object(dep_name)
      result = @objects.select { |obj| obj.name == dep_name }

      raise AmbiguousDependencyError if result.size > 1
      raise DependencyNotExistError if result.empty?

      result[0]
    end
  end
end
