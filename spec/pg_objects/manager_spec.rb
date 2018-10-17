RSpec.describe PgObjects::Manager do
  let(:connection) { instance_double('Connection') }
  let(:ar) { ActiveRecord::Base }

  before do
    allow(ar).to receive(:connection) { connection }
  end

  describe 'db connection' do
    it 'does not work unless adapter is pg' do
      allow(ar.connection).to receive(:adapter_name).and_return('some shitty adapter')
      expect { PgObjects::Manager.new }.to raise_error(PgObjects::UnsupportedAdapterError)
    end

    it 'expects adapter to be postgres' do
      allow(ar.connection).to receive(:adapter_name).and_return('PostgreSQL')
      expect { PgObjects::Manager.new }.not_to raise_error
    end
  end

  describe 'load files' do
    before do
      allow(ar.connection).to receive(:adapter_name).and_return('PostgreSQL')
    end
    
    before do
      fixtures_root_path = File.expand_path 'spec/fixtures/objects'
      PgObjects.config.directories = [fixtures_root_path]

      ['functions/1', 'functions/2', 'triggers/1', 'triggers/2'].each do |sub_path|
        File.open [fixtures_root_path, sub_path, 'test.sql'].join('/'), 'w' do |file|
          file << <<~SQL
            SELECT 1;
          SQL
        end
      end
    end

    it 'loads 4 sql files in directory tree' do
      subject.load_files
      expect(subject.objects.size).to eq 4
    end
  end
end
