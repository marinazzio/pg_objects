#
# RULE object representation
#
class PgObjects::ParsedObject::Rule < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.rule_stmt.rulename }
  end
end
