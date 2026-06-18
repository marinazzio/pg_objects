RSpec.describe PgObjects::Manager do
  include FixtureHelpers

  let(:connection) { double('Connection') } # rubocop: disable RSpec/VerifiedDoubles
  let(:ar) { ActiveRecord::Base }
  let(:fixtures_path) { File.expand_path 'spec/fixtures/objects' }
  let(:extensions) { ['sql'] }
  let(:connection_adapter) { 'PostgreSQL' }

  let(:db_object_factory) { instance_double(PgObjects::DbObjectFactory) }
  let(:db_object) { instance_double(PgObjects::DbObject) }
  let(:config) { PgObjects::Config.config }
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

    context 'when objects share a dependency' do
      let(:db_object_class) do
        Class.new do
          attr_accessor :status, :name, :dependencies, :sql_query
          attr_reader :full_name, :object_name

          def initialize(name:, dependencies: [], sql_query: '')
            @name = name
            @full_name = name
            @object_name = name
            @dependencies = dependencies
            @sql_query = sql_query
            @status = :new
          end
        end
      end

      let(:obj_a) { db_object_class.new(name: 'a', dependencies: ['c'], sql_query: 'A') }
      let(:obj_b) { db_object_class.new(name: 'b', dependencies: ['c'], sql_query: 'B') }
      let(:obj_c) { db_object_class.new(name: 'c', sql_query: 'C') }

      before { subject.objects.push(obj_a, obj_b, obj_c) }

      it 'executes the shared dependency only once', :aggregate_failures do
        subject.create_objects

        expect(ar.connection).to have_received(:execute).with('C').once
        expect(ar.connection).to have_received(:execute).with('A').once
        expect(ar.connection).to have_received(:execute).with('B').once
      end

      it 'marks the shared dependency as done' do
        subject.create_objects

        expect(obj_c.status).to eq(:done)
      end
    end

    context 'with real objects loaded from files' do
      let(:db_object_factory) { PgObjects::DbObjectFactory.new }
      let(:before_dir) { File.join(fixtures_path, 'sql_body_check') }

      let(:sql_bodies) do
        {
          'alpha.sql' => "CREATE FUNCTION alpha() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n",
          'beta.sql' => "CREATE FUNCTION beta() RETURNS integer AS $$ SELECT 2; $$ LANGUAGE sql;\n",
          'gamma.sql' => "CREATE FUNCTION gamma() RETURNS integer AS $$ SELECT 3; $$ LANGUAGE sql;\n"
        }
      end

      before do
        allow(db_object_factory).to receive(:create_instance).and_call_original
        allow(subject.config).to receive(:before_path).and_return(before_dir)

        sql_bodies.each { |name, body| create_file_with('sql_body_check', name, body) }
      end

      it 'passes each fixture file\'s exact SQL body to connection.execute', :aggregate_failures do
        subject.load_files(:before).create_objects

        sql_bodies.each_value do |body|
          expect(ar.connection).to have_received(:execute).with(body).once
        end
      end
    end

    context 'when create_objects is called twice' do
      let(:db_object_class) do
        Class.new do
          attr_accessor :status, :name, :dependencies, :sql_query
          attr_reader :full_name, :object_name

          def initialize(name:, sql_query: '')
            @name = name
            @full_name = name
            @object_name = name
            @dependencies = []
            @sql_query = sql_query
            @status = :new
          end
        end
      end

      let(:obj_x) { db_object_class.new(name: 'x', sql_query: 'X') }
      let(:obj_y) { db_object_class.new(name: 'y', sql_query: 'Y') }

      before { subject.objects.push(obj_x, obj_y) }

      it 'does not re-execute objects that are already done', :aggregate_failures do
        subject.create_objects
        subject.create_objects

        expect(ar.connection).to have_received(:execute).with('X').once
        expect(ar.connection).to have_received(:execute).with('Y').once
      end
    end
  end
end
