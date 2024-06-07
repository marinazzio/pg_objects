require_relative 'shared/context'
require_relative 'shared/examples'

RSpec.describe PgObjects::ParsedObject::Operator do
  include_context 'with parsed object context'

  let(:object_name) { '+-*/<>=~!@#%^&|`'.chars.sample }

  it_behaves_like 'parsed object'
end
