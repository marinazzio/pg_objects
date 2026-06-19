RSpec.describe PgObjects::ParsedObject::Base do
  subject(:base) { described_class.new(stmt) }

  let(:stmt) { PgQuery.parse('SELECT 1;').tree.stmts[0].stmt }

  describe '#name' do
    it 'raises NotImplementedError' do
      expect { base.name }.to raise_error(NotImplementedError)
    end
  end

  describe 'name extraction error handling' do
    let(:nil_deref_subclass) do
      Class.new(described_class) { def name = extract_name { nil.relname } }
    end

    let(:real_error_subclass) do
      Class.new(described_class) { def name = extract_name { 'a string'.no_such_method } }
    end

    it 'wraps a nil dereference in MalformedStatementError' do
      expect { nil_deref_subclass.new(stmt).name }.to raise_error(PgObjects::MalformedStatementError)
    end

    it 'propagates a NoMethodError not caused by a nil receiver' do
      expect { real_error_subclass.new(stmt).name }.to raise_error(NoMethodError, /no_such_method/)
    end
  end
end
