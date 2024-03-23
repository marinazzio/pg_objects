##
# Represents DB object as it is described in file
#
# [name]  name of file without extension
# [full_name] full pathname of file
# [object_name] name of function, trigger etc. if it was successfully parsed, otherwise - nil
class PgObjects::DbObject
  include ::Import['parser']

  attr_reader :sql_query, :name, :full_name, :object_name, :dependencies
  attr_accessor :status

  def initialize(file_path)
    @full_name = file_path
    @name = File.basename(file_path, '.*')

    @status = :new
  end

  def create
    @sql_query = File.read(full_name)

    parser.load(sql_query)

    directives = parser.fetch_directives
    @dependencies = directives[:depends_on]
    @object_name = parser.fetch_object_name

    @status = :pending

    self
  end
end
