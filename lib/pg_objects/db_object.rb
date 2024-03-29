##
# Represents DB object as it is described in file
#
# [name]  name of file without extension
# [full_name] full pathname of file
# [object_name] name of function, trigger etc. if it was successfully parsed, otherwise - nil
class PgObjects::DbObject
  include Memery

  include Import['parser']

  attr_accessor :status
  attr_reader :full_name, :object_name

  def initialize(path, status = :new)
    @full_name = path
    @status = status
  end

  def create
    parser.load(sql_query)
    @object_name = parser.fetch_object_name
    @status = :pending

    self
  end

  memoize
  def name
    File.basename(full_name, '.*')
  end

  memoize
  def dependencies
    parser.fetch_directives[:depends_on]
  end

  memoize
  def sql_query
    File.read(full_name)
  end
end
