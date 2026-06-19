#
# TABLE object representation
#
class PgObjects::ParsedObject::Table < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_stmt.relation.relname }
  end
end
