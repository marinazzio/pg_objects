#
# Base class for parsed objects
#
class PgObjects::ParsedObject::Base
  def initialize(input_data)
    @input_data = input_data
  end
end
