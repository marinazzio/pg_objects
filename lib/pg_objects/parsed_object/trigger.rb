#
# TRIGGER object representation
#
class PgObjects::ParsedObject::Trigger < PgObjects::ParsedObject::Base
  def name
    stmt.create_trig_stmt.trigname
  end
end
