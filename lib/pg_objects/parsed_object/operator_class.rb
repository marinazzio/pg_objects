#
# OPERATOR CLASS object representation
#
class PgObjects::ParsedObject::OperatorClass < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_op_class_stmt.opclassname.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.create_op_class_stmt.opclassname) }
  end
end
