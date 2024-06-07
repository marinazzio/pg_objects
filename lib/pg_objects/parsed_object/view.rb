#
# VIEW object representation
#
class PgObjects::ParsedObject::View < PgObjects::ParsedObject::Base
  def name
    stmt.view_stmt.view.relname
  end
end
