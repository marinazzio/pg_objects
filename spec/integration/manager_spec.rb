RSpec.describe 'Manager integration with real fixtures' do
  include FixtureHelpers

  let(:ar) { ActiveRecord::Base }
  let(:connection) { double('Connection') } # rubocop:disable RSpec/VerifiedDoubles
  let(:logger) { instance_double(PgObjects::Logger, write: nil) }
  let(:config) { PgObjects::Config.config }
  let(:integration_path) { File.join(fixtures_root_path, 'integration') }
  let(:executed) { [] }

  subject(:manager) do
    PgObjects::Manager.new(db_object_factory: PgObjects::DbObjectFactory.new, config:, logger:)
  end

  before do
    allow(ar).to receive(:connection) { connection }
    allow(connection).to receive(:adapter_name).and_return('PostgreSQL')
    allow(connection).to receive(:execute) { |sql| executed << sql }

    allow(config).to receive_messages(before_path: integration_path, extensions: ['sql'], silent: true)
  end

  context 'with a simple dependency (a depends_on b)' do
    it 'executes the dependency before the dependent' do
      sql_b = create_object_fixture('b')
      sql_a = create_object_fixture('a', deps: ['b'])

      manager.load_files(:before).create_objects

      expect(executed.index(sql_b)).to be < executed.index(sql_a)
    end
  end

  context 'with a linear chain a -> b -> c -> d' do
    it 'executes objects in linear dependency order' do
      sql_d = create_object_fixture('d')
      sql_c = create_object_fixture('c', deps: ['d'])
      sql_b = create_object_fixture('b', deps: ['c'])
      sql_a = create_object_fixture('a', deps: ['b'])

      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_d, sql_c, sql_b, sql_a])
    end
  end

  context 'with a diamond graph (a -> b, a -> c, b -> d, c -> d)' do
    it 'executes the shared dependency once, before its dependents', :aggregate_failures do
      sql_d = create_object_fixture('d')
      sql_b = create_object_fixture('b', deps: ['d'])
      sql_c = create_object_fixture('c', deps: ['d'])
      sql_a = create_object_fixture('a', deps: %w[b c])

      manager.load_files(:before).create_objects

      expect(executed.count(sql_d)).to eq(1)
      expect(executed.index(sql_d)).to be < executed.index(sql_b)
      expect(executed.index(sql_d)).to be < executed.index(sql_c)
      expect(executed.index(sql_b)).to be < executed.index(sql_a)
      expect(executed.index(sql_c)).to be < executed.index(sql_a)
    end
  end
end
