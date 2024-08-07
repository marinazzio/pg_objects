RSpec.describe PgObjects::DbObjectFactory do
  subject { described_class.new(parser:) }

  let(:path) { 'path/to/db_object.sql' }
  let(:parser) { instance_double(PgObjects::Parser) }

  describe '#create_instance' do
    before do
      allow(PgObjects::DbObject).to receive(:new).and_call_original
      allow_any_instance_of(PgObjects::DbObject).to receive(:create).and_return(nil) # rubocop:disable RSpec/AnyInstance
    end

    it 'creates a new DbObject instance with the given path and status' do
      subject.create_instance(path, status: :new)

      expect(PgObjects::DbObject).to have_received(:new).with(path, :new, parser:)
    end
  end
end
