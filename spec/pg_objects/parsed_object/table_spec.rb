require_relative 'shared/context'
require_relative 'shared/examples'

RSpec.describe PgObjects::ParsedObject::Table do
  include_context 'with parsed object context'
  it_behaves_like 'parsed object'
end