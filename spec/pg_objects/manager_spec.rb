RSpec.describe PgObjects::Manager do
  include FixtureHelpers

  let(:connection) { instance_double(Connection) }
  let(:ar) { ActiveRecord::Base }
  let(:fixtures_path) { File.expand_path 'spec/fixtures/objects' }
  let(:extension) { 'sql' }

  before do
    allow(ar).to receive(:connection) { connection }
    allow(ar.connection).to receive(:adapter_name).and_return('PostgreSQL')
    allow(ar.connection).to receive(:exec_query)
    allow(ar.connection).to receive(:execute)

    PgObjects.configure do |cfg|
      cfg.before_path = File.join(fixtures_path, 'before')
      cfg.after_path = File.join(fixtures_path, 'after')
      cfg.extensions = [extension]
      cfg.silent = true
    end
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
      subject.load_files(:before)
      expect(subject.objects.size).to eq(fixtures_list(:before, extension).size)
    end

    it 'throws error in the case of ambiguity of dependency' do
      PgObjects.config.extensions << 'sql_amb'
      expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::AmbiguousDependencyError, 'simple_function')
      PgObjects.config.extensions.pop
    end

    it 'throws error when dependency does not exist' do
      PgObjects.config.extensions << 'sql_dne'
      expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::DependencyNotExistError, 'sdlkfjwelkrj')
      PgObjects.config.extensions.pop
    end

    it 'throws error when object is self-dependent' do
      PgObjects.config.extensions << 'sql_clc'
      expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::CyclicDependencyError, 'cyclic_dependence')
      PgObjects.config.extensions.pop
    end
  end
end
