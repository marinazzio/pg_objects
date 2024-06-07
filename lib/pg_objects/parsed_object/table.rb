#
# TABLE object representation
#
class PgObjects::ParsedObject::Table < PgObjects::ParsedObject::Base
  def name
    stmt.create_stmt.relation.relname
  end
end
