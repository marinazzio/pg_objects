RSpec.describe PgObjects::Manager do
  include FixtureHelpers

  let(:connection) { instance_double('Connection') }
  let(:ar) { ActiveRecord::Base }
  let(:fixtures_path) { File.expand_path 'spec/fixtures/objects' }
  let(:extension) { 'sql' }

  before do
    allow(ar).to receive(:connection) { connection }
    allow(ar.connection).to receive(:adapter_name).and_return('PostgreSQL')
    PgObjects.config.directories = [fixtures_path]
    PgObjects.config.extensions = [extension]
  end

  describe 'db connection' do
    it 'does not work unless adapter is pg' do
      allow(ar.connection).to receive(:adapter_name).and_return('some shitty adapter')
      expect { PgObjects::Manager.new }.to raise_error(PgObjects::UnsupportedAdapterError)
    end

    it 'expects adapter to be postgres' do
      expect { PgObjects::Manager.new }.not_to raise_error
    end
  end

  describe 'load files' do
    it 'loads 4 sql files in directory tree' do
      subject.load_files
      expect(subject.objects.size).to eq(fixtures_list(extension).size)
    end
  end
end
