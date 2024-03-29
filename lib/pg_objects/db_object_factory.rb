# frozen_string_literal: true

class PgObjects::DbObjectFactory
  include Import['parser']

  def create_instance(path, status: :new)
    db_object = PgObjects::DbObject.new(path, status)
    db_object.create
  end
end
