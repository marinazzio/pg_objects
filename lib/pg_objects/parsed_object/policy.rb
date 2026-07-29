# frozen_string_literal: true

#
# POLICY object representation
#
class PgObjects::ParsedObject::Policy < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_policy_stmt.policy_name }
  end
end
