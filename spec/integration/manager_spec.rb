RSpec.describe 'Manager integration with real fixtures' do
  include FixtureHelpers

  let(:ar) { ActiveRecord::Base }
  let(:connection) { double('Connection') } # rubocop:disable RSpec/VerifiedDoubles
  let(:logger) { instance_double(PgObjects::Logger, write: nil) }
  let(:config) { PgObjects::Config.config }
  let(:integration_path) { File.join(fixtures_root_path, 'integration') }
  let(:executed) { [] }
  let(:extensions) { ['sql'] }

  subject(:manager) do
    PgObjects::Manager.new(db_object_factory: PgObjects::DbObjectFactory.new, config:, logger:)
  end

  before do
    FileUtils.rm_rf(integration_path) # isolate each example's fixture set

    allow(ar).to receive(:connection) { connection }
    allow(connection).to receive(:adapter_name).and_return('PostgreSQL')
    allow(connection).to receive(:execute) { |sql| executed << sql }

    allow(config).to receive_messages(before_path: integration_path, extensions:, silent: true)
  end

  context 'with a simple dependency (a depends_on b)' do
    it 'executes the dependency before the dependent' do
      sql_b = create_object_fixture('b')
      sql_a = create_object_fixture('a', deps: ['b'])

      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_b, sql_a])
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

  context 'with same-named objects in different schemas' do
    let(:sql_app) { "CREATE FUNCTION app.thing() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n" }
    let(:sql_audit) { "CREATE FUNCTION audit.thing() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n" }
    let(:sql_consumer) do
      "--!depends_on app.thing\nCREATE FUNCTION consumer() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n"
    end

    before do
      # Consumer loads first (alphabetical glob) so the schema-qualified
      # directive — not file order — must drive resolution of app.thing.
      create_file_with('integration', '1_consumer.sql', sql_consumer)
      create_file_with('integration', '2_app_thing.sql', sql_app)
      create_file_with('integration', '3_audit_thing.sql', sql_audit)
    end

    it 'resolves the schema-qualified dependency unambiguously and in order' do
      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_app, sql_consumer, sql_audit])
    end
  end

  context 'with a diamond graph (a -> b, a -> c, b -> d, c -> d)' do
    it 'executes the shared dependency once, before its dependents' do
      sql_d = create_object_fixture('d')
      sql_b = create_object_fixture('b', deps: ['d'])
      sql_c = create_object_fixture('c', deps: ['d'])
      sql_a = create_object_fixture('a', deps: %w[b c])

      manager.load_files(:before).create_objects

      # d resolved once and first; a last; b/c follow a's declared dependency order
      expect(executed).to eq([sql_d, sql_b, sql_c, sql_a])
    end
  end

  context 'with a deep dependency chain built via the chain helper' do
    it 'executes a four-level chain in dependency order' do
      sql_a, sql_b, sql_c, sql_d = create_dependency_chain(%w[a b c d])

      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_d, sql_c, sql_b, sql_a])
    end
  end

  context 'with comma-separated dependencies on a single directive line' do
    it 'resolves every dependency listed on one line' do
      sql_b = create_object_fixture('b')
      sql_c = create_object_fixture('c')
      sql_a = create_object_fixture('a', deps: %w[b c], single_line_deps: true)

      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_b, sql_c, sql_a])
    end
  end

  context 'with a schema-qualified dependency' do
    it 'resolves a dependency that is referenced by its schema-qualified name' do
      sql_dep = create_object_fixture('thing', schema: 'app')
      sql_consumer = create_object_fixture('consumer', deps: ['app.thing'])

      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_dep, sql_consumer])
    end
  end

  context 'with mixed file extensions' do
    let(:extensions) { %w[sql txt] }

    it 'loads and resolves objects across different extensions' do
      sql_dep = create_object_fixture('dep', extension: 'txt')
      sql_consumer = create_object_fixture('consumer', deps: ['dep'], extension: 'sql')

      manager.load_files(:before).create_objects

      expect(executed).to eq([sql_dep, sql_consumer])
    end
  end
end
