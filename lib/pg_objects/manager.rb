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
    end
  end
end
