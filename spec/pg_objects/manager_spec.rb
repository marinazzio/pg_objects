RSpec.describe PgObjects::Manager do
  include FixtureHelpers

  let(:connection) { double('Connection') } # rubocop: disable RSpec/VerifiedDoubles
  let(:ar) { ActiveRecord::Base }
  let(:fixtures_path) { File.expand_path 'spec/fixtures/objects' }
  let(:extensions) { ['sql'] }
  let(:connection_adapter) { 'PostgreSQL' }

  let(:db_object_factory) { instance_double(PgObjects::DbObjectFactory) }
  let(:db_object) { instance_double(PgObjects::DbObject) }
  let(:config) { instance_double(PgObjects::Config) }
  let(:logger) { instance_double(PgObjects::Logger) }

  subject { described_class.new(db_object_factory:, config:, logger:) }

  before do
    allow(subject.logger).to receive(:write)

    allow(ar).to receive(:connection) { connection }
    allow(ar.connection).to receive(:adapter_name).and_return(connection_adapter)
    allow(ar.connection).to receive(:exec_query)
    allow(ar.connection).to receive(:execute)

    allow(subject.config).to receive_messages(
      before_path: File.join(fixtures_path, 'before'),
      after_path: File.join(fixtures_path, 'after'),
      extensions:,
      silent: true
    )

    allow(db_object_factory).to receive(:create_instance).and_return(db_object)
    allow(db_object).to receive_messages(
      :status= => nil,
      status: :new,
      name: '',
      full_name: '',
      object_name: '',
      sql_query: ''
    )
  end

  describe 'db connection' do
    context 'with non pg adapter' do
      let(:connection_adapter) { 'Unknown' }

      it 'does not work' do
        expect { subject.load_files(:before) }.to raise_error(PgObjects::UnsupportedAdapterError)
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

      before do
        allow(db_object).to receive_messages(
          dependencies: ['simple_function'],
          name: 'simple_function'
        )
      end

      it 'throws error' do
        expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::AmbiguousDependencyError, 'simple_function')
      end
    end

    context 'with non-existent dependencies' do
      let(:extensions) { %w[sql sql_dne] }

      before do
        allow(db_object).to receive_messages(
          dependencies: ['sdlkfjwelkrj'],
          name: 'simple_function'
        )
      end

      it 'throws error' do
        expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::DependencyNotExistError, 'sdlkfjwelkrj')
      end
    end

    context 'with cyclic dependencies' do
      let(:extensions) { %w[sql_clc] }

      before do
        allow(db_object).to receive_messages(
          dependencies: ['cyclic_dependence'],
          name: 'cyclic_dependence',
          status: :processing
        )
      end

      it 'throws error' do
        expect { subject.load_files(:before).create_objects }.to raise_error(PgObjects::CyclicDependencyError, 'cyclic_dependence')
      end
    end
  end
end
