# frozen_string_literal: true

##
# Factory for DbObject
#
# Each DbObject gets its own Parser instance so the parser's mutable `@source` is never shared between objects.
class PgObjects::DbObjectFactory
  def create_instance(path, status: :new)
    PgObjects::DbObject.new(path, status, parser: PgObjects::Parser.new).create
  end
end
