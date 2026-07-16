#
# Returns an object of the respective class based on the provided parsed query
#
class PgObjects::ParsedObjectFactory
  DISPATCH = {
    composite_type_stmt: PgObjects::ParsedObject::Type,
    create_conversion_stmt: PgObjects::ParsedObject::Conversion,
    create_event_trig_stmt: PgObjects::ParsedObject::EventTrigger,
    create_function_stmt: PgObjects::ParsedObject::Function,
    create_op_class_stmt: PgObjects::ParsedObject::OperatorClass,
    create_stmt: PgObjects::ParsedObject::Table,
    create_trig_stmt: PgObjects::ParsedObject::Trigger,
    view_stmt: PgObjects::ParsedObject::View
  }.freeze

  DEFINE_STMT_DISPATCH = {
    OBJECT_AGGREGATE: PgObjects::ParsedObject::Aggregate,
    OBJECT_OPERATOR: PgObjects::ParsedObject::Operator,
    OBJECT_TSPARSER: PgObjects::ParsedObject::TextSearchParser,
    OBJECT_TSTEMPLATE: PgObjects::ParsedObject::TextSearchTemplate
  }.freeze

  def self.create_object(input_data)
    new(input_data).create_object
  end

  def initialize(input_data)
    @input_data = input_data
    @stmt = input_data.tree.stmts[0].stmt
  end

  def create_object
    determine_class.new(stmt)
  end

  private

  attr_reader :stmt, :input_data

  def determine_class
    dispatch_class || raise(PgObjects::UnknownObjectTypeError, "unknown object type: #{stmt.node}")
  end

  def dispatch_class
    case stmt.node
    when :define_stmt
      DEFINE_STMT_DISPATCH[stmt.define_stmt.kind]
    when :create_table_as_stmt
      PgObjects::ParsedObject::MaterializedView if stmt.create_table_as_stmt.objtype == :OBJECT_MATVIEW
    else
      DISPATCH[stmt.node]
    end
  end
end
