require 'pg_query'

module PgObjects
  ##
  # Reads directives from SQL-comments
  #
  #    --!depends_on [name_of_dependency]
  #
  # name_of_dependency: short or full name of object as well as object_name
  #
  #    --!multistatement
  #
  # use when there are more than one SQL command in object file
  class Parser
    class << self
      def fetch_directives(text)
        {
          depends_on: fetch_dependencies(text),
          multistatement: fetch_multistatement(text)
        }
      end

      def fetch_object_name(text)
        parsed = PgQuery.parse(text).tree.dig(0, 'RawStmt', 'stmt')
        parsed.dig('CreateTrigStmt', 'trigname') || parsed.dig('CreateFunctionStmt', 'funcname', 0, 'String', 'str')
      rescue PgQuery::ParseError
        nil
      end

      private

      def fetch_dependencies(text)
        text.split("\n").select { |ln| ln =~ /^(--|#)!/ }.map { |ln| ln.split(' ')[1] if ln =~ /!depends_on/ }.compact
      end

      def fetch_multistatement(text)
        text.split("\n").select { |ln| ln =~ /^(--|#)!/ }.select { |ln| ln =~ /!multistatement/ }.present?
      end
    end
  end
end
