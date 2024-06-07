class PgObjects::ParsedObject::Type < PgObjects::ParsedObject::Base
  def name
    stmt.composite_type_stmt.typevar.relname
  end
end
