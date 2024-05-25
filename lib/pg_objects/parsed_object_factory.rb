class PgObjects::ParsedObjectFactory
  def self.create_object(input_data)
    PgObjects::ParsedObject::Trigger.new
  end
end
