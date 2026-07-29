# frozen_string_literal: true

#
# INDEX object representation
#
class PgObjects::ParsedObject::Index < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.index_stmt.idxname }
  end

  private

  # An index lives in the schema of the table it indexes.
  def schema
    extract_name { stmt.index_stmt.relation.schemaname }
  end
end
