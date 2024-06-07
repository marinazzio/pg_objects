#
# Base class for parsed objects
#
class PgObjects::ParsedObject::Base
  def initialize(stmt)
    @stmt = stmt
  end

  def name
    raise NotImplementedError
  end

  private

  attr_reader :stmt
end
