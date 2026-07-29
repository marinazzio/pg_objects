#
# RANGE TYPE object representation (CREATE TYPE ... AS RANGE)
#
class PgObjects::ParsedObject::RangeType < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_range_stmt.type_name.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.create_range_stmt.type_name) }
  end
end
