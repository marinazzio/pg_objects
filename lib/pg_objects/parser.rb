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
    # rubocop: disable Style/WordArray
    ROUTES = [
      ['DefineStmt', 'defnames', 0, 'String', 'str'],
      ['CreateFunctionStmt', 'funcname', 0, 'String', 'str'],
      ['CreateTrigStmt', 'trigname'],
      ['CreateEventTrigStmt', 'trigname'],
      ['CompositeTypeStmt', 'typevar', 'RangeVar', 'relname'],
      ['ViewStmt', 'view', 'RangeVar', 'relname'],
      ['CreateConversionStmt', 'conversion_name', 0, 'String', 'str'],
      ['CreateTableAsStmt', 'into', 'IntoClause', 'rel', 'RangeVar', 'relname'],
      ['CreateOpClassStmt', 'opclassname', 0, 'String', 'str']
    ].freeze
    # rubocop: enable Style/WordArray

    class << self
      def fetch_directives(text)
        {
          depends_on: fetch_dependencies(text)
        }
      end

      # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      def fetch_object_name(text)
        parsed = PgQuery.parse(text)

        return parsed.functions[0] if function?(parsed)
        return parsed.tree.stmts[0].stmt.create_trig_stmt.trigname if trigger?(parsed)
        return parsed.tree.stmts[0].stmt.define_stmt.defnames[0].string.sval if define_statement?(parsed)
        return parsed.tree.stmts[0].stmt.create_conversion_stmt.conversion_name[0].string.sval if conversion?(parsed)
        return parsed.tree.stmts[0].stmt.create_event_trig_stmt.trigname if event_trigger?(parsed)
        return parsed.tree.stmts[0].stmt.create_op_class_stmt.opclassname[0].string.sval if operator_class?(parsed)
        return parsed.tree.stmts[0].stmt.composite_type_stmt.typevar.relname if type?(parsed)

        parsed.tables[0] if table?(parsed)
      rescue PgQuery::ParseError, NoMethodError
        nil
      end
      # rubocop: enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

      private

      def fetch_dependencies(text)
        text.split("\n").grep(/^(--|#)!/).map { |ln| ln.split[1] if ln =~ /!depends_on/ }.compact
      end

      # also views
      def table?(parsed)
        parsed.tables.size.positive?
      end

      def operator_class?(parsed)
        stmt = parsed.tree.stmts[0].stmt
        stmt.respond_to?(:create_op_class_stmt) && stmt.create_op_class_stmt.present?
      end

      def function?(parsed)
        parsed.functions.size.positive?
      end

      def trigger?(parsed)
        stmt = parsed.tree.stmts[0].stmt
        stmt.respond_to?(:create_trig_stmt) && stmt.create_trig_stmt.present?
      end

      def define_statement?(parsed)
        stmt = parsed.tree.stmts[0].stmt
        stmt.respond_to?(:define_stmt) && stmt.define_stmt.present?
      end

      def conversion?(parsed)
        stmt = parsed.tree.stmts[0].stmt
        stmt.respond_to?(:create_conversion_stmt) && stmt.create_conversion_stmt.present?
      end

      def event_trigger?(parsed)
        stmt = parsed.tree.stmts[0].stmt
        stmt.respond_to?(:create_event_trig_stmt) && stmt.create_event_trig_stmt.present?
      end

      def type?(parsed)
        stmt = parsed.tree.stmts[0].stmt
        stmt.respond_to?(:composite_type_stmt) && stmt.composite_type_stmt.present?
      end
    end
  end
end
