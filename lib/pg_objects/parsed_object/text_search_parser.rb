#
# TEXT SEARCH PARSER object representation
#
class PgObjects::ParsedObject::TextSearchParser < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.define_stmt.defnames.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.define_stmt.defnames) }
  end
end
