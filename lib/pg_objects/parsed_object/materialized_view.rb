#
# MATERIALIZED VIEW object representation
#
class PgObjects::ParsedObject::MaterializedView < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_table_as_stmt.into.rel.relname }
  end
end
