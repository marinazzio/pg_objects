#
# FUNCTION object representation
#
class PgObjects::ParsedObject::Function < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_function_stmt.funcname[0].string.sval }
  end
end
