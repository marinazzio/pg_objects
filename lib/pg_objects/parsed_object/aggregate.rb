#
# AGGREGATE object representation
#
class PgObjects::ParsedObject::Aggregate < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.define_stmt.defnames[0].string.sval }
  end
end
