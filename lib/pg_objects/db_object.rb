module PgObjects
  ##
  # Represents DB object as it is described in file
  #
  # [name]  name of file without extension
  # [full_name] full pathname of file
  # [object_name] name of function, trigger etc. if it was successfully parsed, otherwise - nil
  class DbObject
    attr_reader :sql_query, :name, :full_name, :object_name, :dependencies
    attr_accessor :status

    def initialize(file_path)
      @full_name = file_path
      @name = File.basename file_path, '.*'
      @sql_query = File.read file_path

      directives = Parser.fetch_directives @sql_query
      @dependencies = directives[:depends_on]
      @multistatement = directives[:multistatement]
      @object_name = Parser.fetch_object_name @sql_query

      @status = :pending
    end

    def multistatement?
      @multistatement
    end
  end
end
