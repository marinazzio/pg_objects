# frozen_string_literal: true

#
# SEQUENCE object representation
#
class PgObjects::ParsedObject::Sequence < PgObjects::ParsedObject::Base
  def name
    extract_name { stmt.create_seq_stmt.sequence.relname }
  end

  private

  def schema
    extract_name { stmt.create_seq_stmt.sequence.schemaname }
  end
end
