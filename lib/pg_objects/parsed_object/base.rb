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

  # Schema-qualified name (+schema.name+) when a schema is present, otherwise
  # the same as +name+. Used to disambiguate same-named objects across schemas.
  def qualified_name
    schema_name = schema
    schema_name && !schema_name.empty? ? "#{schema_name}.#{name}" : name
  end

  private

  attr_reader :stmt

  # Schema of the object, or nil when unqualified. Subclasses that carry a
  # schema override this; the rest inherit the unqualified default.
  def schema
    nil
  end

  # Returns the schema element of a pg_query name list (e.g. funcname,
  # defnames) when the name is qualified (+schema.name+), otherwise nil.
  def qualifier(list)
    list[-2].string.sval if list.size > 1
  end

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
