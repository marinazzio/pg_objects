RSpec.describe PgObjects::DbObject do
  include FixtureHelpers

  let(:file_path) { fixtures_list('sql').first }
  let(:subject) { described_class.new(file_path) }

  it 'has sql_query equal to file content' do
    expect(subject.sql_query).to eq(File.read(file_path))
  end

  it 'has name equal to extensionless file name' do
    expect(subject.name).to eq(File.basename(file_path, '.*'))
  end

  it 'has dependencies when there is a proper directive' do
    create_file_with 'directive', 'another.sql', 'SELECT 1;'
    alt_path = create_file_with 'directive', 'proper.sql', <<~SQL
      --!depends_on another
      SELECT 1;
    SQL

    expect(described_class.new(alt_path).dependencies).to include('another')
  end
end
