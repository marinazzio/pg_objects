#
# CONVERSION object representation
#
class PgObjects::ParsedObject::Conversion < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_conversion_stmt.conversion_name.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.create_conversion_stmt.conversion_name) }
  end
end
