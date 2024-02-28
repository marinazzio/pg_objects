RSpec.describe PgObjects::Manager do
  include FixtureHelpers

  subject { described_class.new(config, logger) }

  let(:config) { instance_double(PgObjects::Config) }
  let(:logger) { instance_double(PgObjects::Logger) }

  let(:connection) { double('Connection') } # rubocop: disable RSpec/VerifiedDoubles
  let(:ar) { ActiveRecord::Base }
  let(:fixtures_path) { File.expand_path 'spec/fixtures/objects' }
  let(:extensions) { ['sql'] }
  let(:connection_adapter) { 'PostgreSQL' }

  before do
    allow(logger).to receive(:mute).and_return(logger)
    allow(logger).to receive(:write)

    allow(ar).to receive(:connection) { connection }
    allow(ar.connection).to receive(:adapter_name).and_return(connection_adapter)
    allow(ar.connection).to receive(:exec_query)
    allow(ar.connection).to receive(:execute)

    allow(config).to receive_messages(
      before_path: File.join(fixtures_path, 'before'),
      after_path: File.join(fixtures_path, 'after'),
      extensions:,
      silent: true
    )
  end

  describe 'db connection' do
    context 'with non pg adapter' do
      let(:connection_adapter) { 'Unknown' }

      it 'does not work' do
        expect { subject }.to raise_error(PgObjects::UnsupportedAdapterError)
      end
    end

    it 'is ready to work' do
      expect { subject }.not_to raise_error
    end
  end

  describe 'create objects' do
    it 'loads sql files in directory tree' do
      subject.load_files(:before)
      expect(subject.objects.size).to eq(fixtures_list(:before, extensions.first).size)
    end

    context 'with ambiguous dependencies' do
      let(:extensions) { %w[sql sql_amb] }

      it 'throws error' do
        expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::AmbiguousDependencyError, 'simple_function')
      end
    end

    context 'with non-existent dependencies' do
      let(:extensions) { %w[sql sql_dne] }

      it 'throws error' do
        expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::DependencyNotExistError, 'sdlkfjwelkrj')
      end
    end

    context 'with cyclic dependencies' do
      let(:extensions) { %w[sql sql_clc] }

      it 'throws error' do
        expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::CyclicDependencyError, 'cyclic_dependence')
      end
    end
  end
end
