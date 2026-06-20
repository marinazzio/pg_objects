#
# TABLE object representation
#
class PgObjects::ParsedObject::Table < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_stmt.relation.relname }
  end

  private

  def schema
    extract_name { stmt.create_stmt.relation.schemaname }
  end
end
