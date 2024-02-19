require 'dry/monads'
require 'pg_query'

##
# Reads directives from SQL-comments
#
#    --!depends_on [name_of_dependency]
#
# name_of_dependency: short or full name of object as well as object_name
#
class PgObjects::Parser
  def initialize(source)
    @source = source
  end

  def fetch_directives
    {
      depends_on: fetch_dependencies
    }
  end

  # rubocop: disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def fetch_object_name
    return parsed.functions[0] if function?
    return parsed.tree.stmts[0].stmt.create_trig_stmt.trigname if trigger?
    return parsed.tree.stmts[0].stmt.define_stmt.defnames[0].string.sval if define_statement?
    return parsed.tree.stmts[0].stmt.create_conversion_stmt.conversion_name[0].string.sval if conversion?
    return parsed.tree.stmts[0].stmt.create_event_trig_stmt.trigname if event_trigger?
    return parsed.tree.stmts[0].stmt.create_op_class_stmt.opclassname[0].string.sval if operator_class?
    return parsed.tree.stmts[0].stmt.composite_type_stmt.typevar.relname if type?

    parsed.tables[0] if table?
  rescue PgQuery::ParseError, NoMethodError
    nil
  end
  # rubocop: enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def parsed
    @parsed ||= PgQuery.parse(@source)
  end

  def fetch_dependencies
    @source.split("\n").grep(/^(--|#)!/).map { |ln| ln.split[1] if ln =~ /!depends_on/ }.compact
  end

  # also views
  def table?
    parsed.tables.size.positive?
  end

  def operator_class?
    stmt = parsed.tree.stmts[0].stmt
    stmt.respond_to?(:create_op_class_stmt) && stmt.create_op_class_stmt.present?
  end

  def function?
    parsed.functions.size.positive?
  end

  def trigger?
    stmt = parsed.tree.stmts[0].stmt
    stmt.respond_to?(:create_trig_stmt) && stmt.create_trig_stmt.present?
  end

  def define_statement?
    stmt = parsed.tree.stmts[0].stmt
    stmt.respond_to?(:define_stmt) && stmt.define_stmt.present?
  end

  def conversion?
    stmt = parsed.tree.stmts[0].stmt
    stmt.respond_to?(:create_conversion_stmt) && stmt.create_conversion_stmt.present?
  end

  def event_trigger?
    stmt = parsed.tree.stmts[0].stmt
    stmt.respond_to?(:create_event_trig_stmt) && stmt.create_event_trig_stmt.present?
  end

  def type?
    stmt = parsed.tree.stmts[0].stmt
    stmt.respond_to?(:composite_type_stmt) && stmt.composite_type_stmt.present?
  end
end
