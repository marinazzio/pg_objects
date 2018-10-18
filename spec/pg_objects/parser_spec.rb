RSpec.describe PgObjects::Parser do
  let(:sql_body) do
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      SELECT 1;
    SQL
  end

  let(:fetched_deps) do
    [
      'here/is/a/path/to/object.sql',
      'some/path/to/another.sql'
    ]
  end

  it 'fetches depends_on directives' do
    expect(described_class.fetch_dependencies(sql_body).sort).to eq(fetched_deps.sort)
  end
end
