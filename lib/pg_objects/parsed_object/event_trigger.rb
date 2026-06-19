#
# EVENT TRIGGER object representation
#
class PgObjects::ParsedObject::EventTrigger < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_event_trig_stmt.trigname }
  end
end
