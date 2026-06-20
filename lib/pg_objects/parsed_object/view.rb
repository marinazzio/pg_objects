#
# VIEW object representation
#
class PgObjects::ParsedObject::View < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.view_stmt.view.relname }
  end

  private

  def schema
    extract_name { stmt.view_stmt.view.schemaname }
  end
end
