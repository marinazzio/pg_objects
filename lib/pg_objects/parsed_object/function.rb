#
# FUNCTION object representation
#
class PgObjects::ParsedObject::Function < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_function_stmt.funcname.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.create_function_stmt.funcname) }
  end
end
