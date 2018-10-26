RSpec.describe PgObjects::DbObject do
  include FixtureHelpers

  let(:file_path) { fixtures_list(:before, 'sql').first }
  let(:subject) { described_class.new(file_path) }

  it 'has sql_query equal to file content' do
    expect(subject.sql_query).to eq(File.read(file_path))
  end

  it 'has name equal to extensionless file name' do
    expect(subject.name).to eq(File.basename(file_path, '.*'))
  end

  it 'has full_name equal to name of file with full path and extension' do
    expect(subject.full_name).to eq(file_path)
  end

  it 'has object_name equal to name of object, parsed from query'

  it 'has dependencies when there is a proper directive' do
    create_file_with 'directive', 'another.sql', 'SELECT 1;'
    alt_path = create_file_with 'directive', 'proper.sql', <<~SQL
      --!depends_on another
      SELECT 1;
    SQL

    expect(described_class.new(alt_path).dependencies).to include('another')
  end

  it 'has multistatement mark when there is a proper directive' do
    sql_path = create_file_with 'multistatement', 'mltsttmnt.sql', <<~SQL
      --!multistatement
      SELECT 1;
      SELECT 2;
    SQL

    expect(described_class.new(sql_path).multistatement?).to be_truthy
  end
end
