RSpec.shared_examples 'parsed object' do
  it 'has a proper object name' do
    expect(subject.name).to eq(object_name)
  end
end

RSpec.shared_examples 'rejects malformed statement' do
  let(:malformed_stmt) { PgQuery.parse('SELECT 1;').tree.stmts[0].stmt }

  it 'raises MalformedStatementError carrying the subclass name' do
    expect { described_class.new(malformed_stmt).name }
      .to raise_error(PgObjects::MalformedStatementError, /#{described_class}/)
  end
end
