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
  # surfaces an explicit error with context. Only NoMethodErrors from
  # dereferencing nil are wrapped; genuine programming errors propagate.
  def extract_name
    yield
  rescue NoMethodError => e
    raise unless nil_dereference?(e)

    raise PgObjects::MalformedStatementError, "malformed statement for #{self.class}: #{e.message}"
  end

  def nil_dereference?(error)
    error.receiver.nil?
  rescue ArgumentError
    false
  end
end
