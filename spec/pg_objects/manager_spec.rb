RSpec.describe PgObjects::Manager do
  include FixtureHelpers

  let(:connection) { instance_double('Connection') }
  let(:ar) { ActiveRecord::Base }
  let(:fixtures_path) { File.expand_path 'spec/fixtures/objects' }
  let(:extension) { 'sql' }

  before do
    allow(ar).to receive(:connection) { connection }
    allow(ar.connection).to receive(:adapter_name).and_return('PostgreSQL')
    allow(ar.connection).to receive(:exec_query)
    PgObjects.config.directories = [fixtures_path]
    PgObjects.config.extensions = [extension]
  end

  describe 'db connection' do
    it 'does not work unless adapter is pg' do
      allow(ar.connection).to receive(:adapter_name).and_return('some shitty adapter')
      expect { described_class.new }.to raise_error(PgObjects::UnsupportedAdapterError)
    end

    it 'expects adapter to be postgres' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe 'create objects' do
    it 'loads sql files in directory tree' do
      subject.load_files
      expect(subject.objects.size).to eq(fixtures_list(extension).size)
    end

    it 'throws error in the case of ambiguity of dependency' do
      PgObjects.config.extensions << 'sql_amb'
      expect { subject.load_files.create_objects }.to raise_error(PgObjects::AmbiguousDependencyError)
      PgObjects.config.extensions.pop
    end

    it 'throws error when dependency does not exist' do
      PgObjects.config.extensions << 'sql_dne'
      expect { subject.load_files.create_objects }.to raise_error(PgObjects::DependencyNotExistError)
      PgObjects.config.extensions.pop
    end

    it 'throws error when object is self-dependent' do
      PgObjects.config.extensions << 'sql_clc'
      expect { subject.load_files.create_objects }.to raise_error(PgObjects::CyclicDependencyError)
      PgObjects.config.extensions.pop
    end
  end
end
