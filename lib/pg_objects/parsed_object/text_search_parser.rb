class PgObjects::ParsedObject::TextSearchParser < PgObjects::ParsedObject::Base
  def name
    stmt.define_stmt.defnames[0].string.sval
  end
end
