require 'pg_query'

##
# Reads directives from SQL-comments
#
#    --!depends_on [name_of_dependency]
#
# name_of_dependency: short or full name of object as well as object_name
#
class PgObjects::Parser
  include Import['parsed_object_factory']
  include Memery

  PG_ENTITIES = %i[operator_class trigger define_statement conversion event_trigger type function table].freeze

  def load(source)
    @source = source
    self
  end

  def fetch_directives
    {
      depends_on: fetch_dependencies
    }
  end

  def fetch_object_name
    parse_query
    parsed_object.name
  rescue PgQuery::ParseError, NoMethodError
    nil
  end

  private

  attr_reader :parsed

  def parse_query
    @parsed = PgQuery.parse(@source)
  end

  memoize
  def parsed_object
    parsed_object_factory.create_object(parsed)
  end

  def fetch_dependencies
    @source.split("\n").grep(/^(--|#)!/).map { |ln| ln.split[1] if ln =~ /!depends_on/ }.compact
  end
end
