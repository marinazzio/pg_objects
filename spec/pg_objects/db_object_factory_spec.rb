RSpec.describe PgObjects::DbObjectFactory do
  subject(:factory) { described_class.new(parser:) }

  let(:path) { 'path/to/db_object.sql' }
  let(:parser) { instance_double(PgObjects::Parser) }
  let(:db_object) { instance_double(PgObjects::DbObject) }

  describe '#create_instance' do
    before do
      allow(PgObjects::DbObject).to receive(:new).with(path, :new, parser:).and_return(db_object)
      allow(db_object).to receive(:create).and_return(db_object)
    end

    it 'creates a new DbObject instance with the given path, status and parser' do
      factory.create_instance(path, status: :new)

      expect(PgObjects::DbObject).to have_received(:new).with(path, :new, parser:)
    end

    it 'invokes #create on the DbObject' do
      factory.create_instance(path, status: :new)

      expect(db_object).to have_received(:create)
    end

    it 'returns the DbObject produced by #create' do
      expect(factory.create_instance(path, status: :new)).to be(db_object)
    end

    it 'defaults the status to :new when none is given' do
      factory.create_instance(path)

      expect(PgObjects::DbObject).to have_received(:new).with(path, :new, parser:)
    end
  end
end
