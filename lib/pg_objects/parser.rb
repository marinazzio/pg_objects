require 'pg_query'

##
# Reads directives from SQL-comments
#
#    --!depends_on name_a
#    --!depends_on name_a, name_b, name_c
#    #!depends_on name_a
#
# The directive must start the line (no leading whitespace). Dependencies may
# be listed on one line separated by commas and/or whitespace, or across
# several directive lines.
#
# name_of_dependency: short or full name of object as well as object_name
#
class PgObjects::Parser
  include Import['parsed_object_factory']

  DEPENDS_ON_DIRECTIVE = /\A(?:--|#)!depends_on\s+(.+)/

  def load(source)
    @source = source
    @parsed = nil
    @parsed_object = nil
    self
  end

  def fetch_directives
    {
      depends_on: fetch_dependencies
    }
  end

  def fetch_object_name
    parsed_object.name
  rescue PgQuery::ParseError, PgObjects::UnknownObjectTypeError
    nil
  end

  def fetch_qualified_object_name
    parsed_object.qualified_name
  rescue PgQuery::ParseError, PgObjects::UnknownObjectTypeError
    nil
  end

  private

  # Parse once per loaded source; both fetch_* methods reuse the result and
  # +load+ clears it, so a new source is always reparsed (no stale cache).
  def parsed
    @parsed ||= PgQuery.parse(@source)
  end

  def parsed_object
    @parsed_object ||= parsed_object_factory.create_object(parsed)
  end

  def fetch_dependencies
    @source.each_line.flat_map do |line|
      match = DEPENDS_ON_DIRECTIVE.match(line)
      match ? match[1].split(/[\s,]+/).reject(&:empty?) : []
    end
  end
end
