#
# ENUM TYPE object representation (CREATE TYPE ... AS ENUM)
#
class PgObjects::ParsedObject::EnumType < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_enum_stmt.type_name.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.create_enum_stmt.type_name) }
  end
end
