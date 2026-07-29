# frozen_string_literal: true

#
# DOMAIN object representation (CREATE DOMAIN)
#
class PgObjects::ParsedObject::Domain < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_domain_stmt.domainname.last.string.sval }
  end

  private

  def schema
    extract_name { qualifier(stmt.create_domain_stmt.domainname) }
  end
end
