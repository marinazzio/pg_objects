class PgObjects::ParsedObject::Function < PgObjects::ParsedObject::Base
  def name
    stmt.create_function_stmt.funcname[0].string.sval
  end
end
