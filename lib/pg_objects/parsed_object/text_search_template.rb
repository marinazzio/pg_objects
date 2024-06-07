#
# TEXT SEARCH TEMPLATE object representation
#
class PgObjects::ParsedObject::TextSearchTemplate < PgObjects::ParsedObject::Base
  def name
    stmt.define_stmt.defnames[0].string.sval
  end
end
