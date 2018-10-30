RSpec.describe PgObjects::Parser do
  let(:sql1_body) do
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      CREATE TRIGGER useless_trigger AFTER INSERT ON some_table
        EXECUTE PROCEDURE nonexistent_function();
    SQL
  end

  let(:sql2_body) do
    <<~SQL
      --!multistatement
      SELECT 345;
      SELECT 456;
    SQL
  end

  let(:fetched_deps) do
    [
      'here/is/a/path/to/object.sql',
      'some/path/to/another.sql'
    ]
  end

  it 'fetches depends_on directives' do
    dirs = described_class.fetch_directives(sql1_body)
    expect(dirs[:depends_on].sort).to eq(fetched_deps.sort)
  end

  it 'fetches multistatement directive' do
    dirs = described_class.fetch_directives(sql2_body)
    expect(dirs[:multistatement]).to be_truthy
  end

  it 'is unable to fetch multistatement directive when one is absent' do
    dirs = described_class.fetch_directives(sql1_body)
    expect(dirs[:multistatement]).to be_falsy
  end

  it 'fetches object_name from sql when it is possible' do
    expect(described_class.fetch_object_name(sql1_body)).to eq('useless_trigger')
  end

  it 'fetches nil as object_name when it is impossible' do
    expect(described_class.fetch_object_name(sql2_body)).to be_nil
  end
end
