require_relative 'shared/context'
require_relative 'shared/examples'

RSpec.describe PgObjects::ParsedObject::TextSearchParser do
  include_context 'parsed object context'
  it_behaves_like 'parsed object'
end
