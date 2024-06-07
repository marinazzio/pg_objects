class PgObjects::ParsedObject::OperatorClass < PgObjects::ParsedObject::Base
  def name
    stmt.create_op_class_stmt.opclassname[0].string.sval
  end
end
