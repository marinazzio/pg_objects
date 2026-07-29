# frozen_string_literal: true

#
# Base (scalar) TYPE object representation (CREATE TYPE with I/O functions or
# a shell CREATE TYPE without attributes) — parsed as a define_stmt.
#
class PgObjects::ParsedObject::BaseType < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.define_stmt.defnames.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.define_stmt.defnames) }
  end
end
