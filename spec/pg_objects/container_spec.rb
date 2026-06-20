RSpec.describe PgObjects::Container do
  describe 'registrations' do
    it 'resolves config to the shared Config.config' do
      expect(described_class.resolve('config')).to equal(PgObjects::Config.config)
    end

    it 'resolves db_object_factory to a DbObjectFactory' do
      expect(described_class.resolve('db_object_factory')).to be_an_instance_of(PgObjects::DbObjectFactory)
    end

    it 'resolves parsed_object_factory to the ParsedObjectFactory class' do
      expect(described_class.resolve('parsed_object_factory')).to eq(PgObjects::ParsedObjectFactory)
    end

    it 'resolves parser to a Parser' do
      expect(described_class.resolve('parser')).to be_an_instance_of(PgObjects::Parser)
    end

    it 'resolves logger to a Logger' do
      expect(described_class.resolve('logger')).to be_an_instance_of(PgObjects::Logger)
    end
  end

  describe 'resolution lifecycle' do
    # A fresh parser per resolve is what lets every DbObject own its parser,
    # so the parser's mutable @source is never shared (see thread-safety work).
    it 'returns a fresh parser on each resolve' do
      expect(described_class.resolve('parser')).not_to equal(described_class.resolve('parser'))
    end

    it 'returns a fresh db_object_factory on each resolve' do
      expect(described_class.resolve('db_object_factory')).not_to equal(described_class.resolve('db_object_factory'))
    end

    it 'returns the same config on each resolve' do
      expect(described_class.resolve('config')).to equal(described_class.resolve('config'))
    end

    it 'returns the same parsed_object_factory class on each resolve' do
      expect(described_class.resolve('parsed_object_factory')).to equal(described_class.resolve('parsed_object_factory'))
    end
  end
end
