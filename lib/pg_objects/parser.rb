require 'pg_query'

module PgObjects
  ##
  # Reads directives from SQL-comments
  #
  #    --!depends_on [name_of_dependency]
  #
  # name_of_dependency: short or full name of object as well as object_name
  #
  class Parser
    ROUTES = [
      ['DefineStmt', 'defnames', 0, 'String', 'str'],
      ['CreateFunctionStmt', 'funcname', 0, 'String', 'str'],
      %w[CreateTrigStmt trigname],
      %w[CreateEventTrigStmt trigname],
      %w[CompositeTypeStmt typevar RangeVar relname],
      %w[ViewStmt view RangeVar relname],
      ['CreateConversionStmt', 'conversion_name', 0, 'String', 'str'],
      %w[CreateTableAsStmt into IntoClause rel RangeVar relname],
      ['CreateOpClassStmt', 'opclassname', 0, 'String', 'str']
    ].freeze

    class << self
      def fetch_directives(text)
        {
          depends_on: fetch_dependencies(text)
        }
      end

      def fetch_object_name(text)
        parsed = PgQuery.parse(text).tree.dig(0, 'RawStmt', 'stmt')
        ROUTES.map { |route| parsed.dig(*route) }.compact[0]
      rescue PgQuery::ParseError, NoMethodError
        nil
      end

      private

      def fetch_dependencies(text)
        text.split("\n").select { |ln| ln =~ /^(--|#)!/ }.map { |ln| ln.split[1] if ln =~ /!depends_on/ }.compact
      end
    end
  end
end
