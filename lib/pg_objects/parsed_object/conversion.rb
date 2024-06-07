#
# CONVERSION object representation
#
class PgObjects::ParsedObject::Conversion < PgObjects::ParsedObject::Base
  def name
    stmt.create_conversion_stmt.conversion_name[0].string.sval
  end
end
