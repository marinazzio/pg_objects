require 'pg_query'

##
# Reads directives from SQL-comments
#
#    --!depends_on [name_of_dependency]
#
# name_of_dependency: short or full name of object as well as object_name
#
class PgObjects::Parser
  PG_ENTITIES = %i[operator_class trigger define_statement conversion event_trigger type function table].freeze

  def initialize(source)
    @source = source
  end

  def fetch_directives
    {
      depends_on: fetch_dependencies
    }
  end

  def fetch_object_name
    parse_query
    object_name
  rescue PgQuery::ParseError, NoMethodError
    nil
  end

  private

  attr_reader :stmt, :parsed

  def parse_query
    @parsed = PgQuery.parse(@source)

    @stmt = parsed.tree.stmts[0].stmt
  end

  def object_name
    PG_ENTITIES.filter_map { |entity| send(:"check_#{entity}") }.first
  end

  def fetch_dependencies
    @source.split("\n").grep(/^(--|#)!/).map { |ln| ln.split[1] if ln =~ /!depends_on/ }.compact
  end

  # also views
  def table? = parsed.tables.size.positive?

  def check_table
    parsed.tables[0] if table?
  end

  def function? = parsed.functions.size.positive?

  def check_function
    parsed.functions[0] if function?
  end

  def operator_class? = stmt.respond_to?(:create_op_class_stmt) && stmt.create_op_class_stmt.present?

  def check_operator_class
    stmt.create_op_class_stmt.opclassname[0].string.sval if operator_class?
  end

  def trigger? = stmt.respond_to?(:create_trig_stmt) && stmt.create_trig_stmt.present?

  def check_trigger
    stmt.create_trig_stmt.trigname if trigger?
  end

  def define_statement? = stmt.respond_to?(:define_stmt) && stmt.define_stmt.present?

  def check_define_statement
    stmt.define_stmt.defnames[0].string.sval if define_statement?
  end

  def conversion? = stmt.respond_to?(:create_conversion_stmt) && stmt.create_conversion_stmt.present?

  def check_conversion
    stmt.create_conversion_stmt.conversion_name[0].string.sval if conversion?
  end

  def event_trigger? = stmt.respond_to?(:create_event_trig_stmt) && stmt.create_event_trig_stmt.present?

  def check_event_trigger
    stmt.create_event_trig_stmt.trigname if event_trigger?
  end

  def type? = stmt.respond_to?(:composite_type_stmt) && stmt.composite_type_stmt.present?

  def check_type
    stmt.composite_type_stmt.typevar.relname if type?
  end
end
