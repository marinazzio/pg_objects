RSpec.describe PgObjects::Parser do
  let(:sql1_body) do
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      SELECT 1;
    SQL
  end

  let(:sql2_body) do
    <<~SQL
      --!multistatement
      SELECT 345;
    SQL
  end

  let(:fetched_deps) do
    [
      'here/is/a/path/to/object.sql',
      'some/path/to/another.sql'
    ]
  end

  it 'fetches depends_on directives' do
    expect(described_class.fetch_dependencies(sql1_body).sort).to eq(fetched_deps.sort)
  end

  it 'fetches multistatement directive' do
    expect(described_class.fetch_multistatement(sql2_body)).to be_truthy
  end

  it 'is unable to fetch multistatement directive when one is absent' do
    expect(described_class.fetch_multistatement(sql1_body)).to be_falsy
  end
end
