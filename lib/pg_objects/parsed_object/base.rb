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

  # Wraps name extraction so a malformed statement (nil field, empty array)
  # surfaces an explicit error with context instead of a bare NoMethodError.
  def extract_name
    yield
  rescue NoMethodError => e
    raise PgObjects::MalformedStatementError, "malformed statement for #{self.class}: #{e.message}"
  end
end
