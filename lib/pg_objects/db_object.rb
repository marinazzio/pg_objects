module PgObjects
  class DbObject
    attr_reader :sql_query

    def initialize(file_path)
      @sql_query = File.read file_path
    end
  end
end
