# frozen_string_literal: true

#
# EXTENSION object representation
#
class PgObjects::ParsedObject::Extension < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_extension_stmt.extname }
  end
end
