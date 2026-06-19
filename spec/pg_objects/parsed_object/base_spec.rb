RSpec.describe PgObjects::ParsedObject::Base do
  subject(:base) { described_class.new(stmt) }

  let(:stmt) { PgQuery.parse('SELECT 1;').tree.stmts[0].stmt }

  describe '#name' do
    it 'raises NotImplementedError' do
      expect { base.name }.to raise_error(NotImplementedError)
    end
  end
end
