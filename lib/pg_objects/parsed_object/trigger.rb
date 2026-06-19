#
# TRIGGER object representation
#
class PgObjects::ParsedObject::Trigger < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_trig_stmt.trigname }
  end
end
