RSpec.describe PgObjects::DbObject do
  include FixtureHelpers

  subject(:db_object) { described_class.new(file_path) }

  let(:file_path) { fixtures_list(:before, 'sql').grep(/uniquely_named_function/).first }

  it 'has name equal to the extensionless file name' do
    expect(db_object.name).to eq(File.basename(file_path, '.*'))
  end

  it 'has full_name equal to the full path of the file with extension' do
    expect(db_object.full_name).to eq(file_path)
  end

  it 'starts with :new status' do
    expect(db_object.status).to eq(:new)
  end

  it 'keeps the status passed to the constructor' do
    expect(described_class.new(file_path, :done).status).to eq(:done)
  end

  it 'has sql_query equal to the file content' do
    expect(db_object.sql_query).to eq(File.read(file_path))
  end

  it 'memoizes sql_query after the first read' do
    create_file_with 'db_object', 'memoized.sql', 'SELECT 1;'
    path = fixtures_list('db_object', 'sql').grep(/memoized/).first
    object = described_class.new(path)

    first_read = object.sql_query
    create_file_with 'db_object', 'memoized.sql', 'SELECT 2;'

    expect(object.sql_query).to eq(first_read)
  end

  it 'returns itself from create' do
    expect(db_object.create).to be(db_object)
  end

  it 'transitions the status from :new to :pending on create' do
    expect { db_object.create }.to change(db_object, :status).from(:new).to(:pending)
  end

  it 'sets object_name parsed from the query on create' do
    expect(db_object.create.object_name).to eq('my_function')
  end

  it 'sets qualified_object_name equal to object_name when the object has no schema' do
    expect(db_object.create.qualified_object_name).to eq('my_function')
  end

  it 'has no dependencies when the source has no directives' do
    expect(db_object.create.dependencies).to eq([])
  end

  context 'when the source cannot be parsed into a known object' do
    let(:file_path) do
      create_file_with 'db_object', 'unparseable.sql', 'SELECT 1;'
      fixtures_list('db_object', 'sql').grep(/unparseable/).first
    end

    it 'leaves object_name nil but still transitions to :pending', :aggregate_failures do
      db_object.create

      expect(db_object.object_name).to be_nil
      expect(db_object.qualified_object_name).to be_nil
      expect(db_object.status).to eq(:pending)
    end
  end

  context 'when the source has depends_on directives' do
    let(:file_path) do
      create_file_with 'db_object', 'dependent.sql', <<~SQL
        --!depends_on another
        SELECT 1;
      SQL
      fixtures_list('db_object', 'sql').grep(/dependent/).first
    end

    it 'returns the parsed dependency names' do
      expect(db_object.create.dependencies).to include('another')
    end
  end
end
