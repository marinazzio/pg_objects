RSpec.describe PgObjects::DbObject do
  let(:file_path) { File.expand_path 'spec/fixtures/objects/functions/1/test.sql' }
  let(:subject) { described_class.new(file_path) }

  it 'has sql_query equal to file content' do
    expect(subject.sql_query).to eq(File.read(file_path))
  end
end
