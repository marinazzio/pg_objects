require_relative 'shared/context'
require_relative 'shared/examples'

RSpec.describe PgObjects::ParsedObject::Operator do
  include_context 'parsed object context'
  let(:object_name) { '+-*/<>=~!@#%^&|`'.split('').sample }
  it_behaves_like 'parsed object'
end
