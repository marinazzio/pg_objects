#
# TYPE object representation
#
class PgObjects::ParsedObject::Type < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.composite_type_stmt.typevar.relname }
  end

  private

  def schema
    extract_name { stmt.composite_type_stmt.typevar.schemaname }
  end
end
