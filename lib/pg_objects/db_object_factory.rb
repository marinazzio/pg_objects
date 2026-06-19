# frozen_string_literal: true

##
# Factory for DbObject
#
# Each DbObject gets its own Parser instance so the parser's mutable `@source`
# is never shared between objects. The parser class is
# injectable so callers/tests can substitute an alternate parser.
class PgObjects::DbObjectFactory
  def initialize(parser_class: PgObjects::Parser)
    @parser_class = parser_class
  end

  def create_instance(path, status: :new)
    PgObjects::DbObject.new(path, status, parser: parser_class.new).create
  end

  private

  attr_reader :parser_class
end
