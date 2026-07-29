#
# INDEX object representation
#
class PgObjects::ParsedObject::Index < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.index_stmt.idxname }
  end
end
