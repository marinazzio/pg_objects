RSpec.describe PgObjects::DbObjectFactory do
  subject(:factory) { described_class.new }

  let(:path) { 'path/to/db_object.sql' }
  let(:db_object) { instance_double(PgObjects::DbObject) }

  describe '#create_instance' do
    before do
      allow(PgObjects::DbObject).to receive(:new)
        .with(path, :new, parser: an_instance_of(PgObjects::Parser)).and_return(db_object)
      allow(db_object).to receive(:create).and_return(db_object)
    end

    it 'creates a new DbObject instance with the given path, status and a fresh parser' do
      factory.create_instance(path, status: :new)

      expect(PgObjects::DbObject).to have_received(:new).with(path, :new, parser: an_instance_of(PgObjects::Parser)).once
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

      expect(PgObjects::DbObject).to have_received(:new).with(path, :new, parser: an_instance_of(PgObjects::Parser)).once
    end

    it 'gives each DbObject its own Parser instance' do
      parsers = []
      allow(PgObjects::DbObject).to receive(:new) do |*_args, parser:|
        parsers << parser
        db_object
      end

      factory.create_instance(path)
      factory.create_instance(path)

      expect(parsers.uniq.size).to eq(2)
    end
  end

  describe 'parser isolation between objects' do
    let(:dependent_path) { fixtures_list(:before, 'sql').grep(/dependent_trigger/).first }
    let(:standalone_path) { fixtures_list(:before, 'sql').grep(/uniquely_named_function/).first }

    it 'parses each object independently without cross-contaminating dependencies', :aggregate_failures do
      dependent = factory.create_instance(dependent_path)
      standalone = factory.create_instance(standalone_path)

      expect(dependent.dependencies).to include('uniquely_named_function')
      expect(standalone.dependencies).to eq([])
    end
  end
end
