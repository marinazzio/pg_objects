module PgObjects
  class DbObject
    attr_reader :sql_query, :name, :full_name, :dependencies
    attr_accessor :status

    def initialize(file_path)
      @full_name = file_path
      @name = File.basename file_path, '.*'
      @sql_query = File.read file_path
      @dependencies = Parser.fetch_dependencies @sql_query
      # @multistatement = Parser.

      @status = :pending
    end

    def multistatement?
      true
    end
  end
end
