RSpec.describe 'Manager integration with real fixtures' do
  include FixtureHelpers

  let(:ar) { ActiveRecord::Base }
  let(:connection) { double('Connection') } # rubocop:disable RSpec/VerifiedDoubles
  let(:logger) { instance_double(PgObjects::Logger, write: nil) }
  let(:config) { PgObjects::Config.config }
  let(:integration_path) { File.join(fixtures_root_path, 'integration') }
  let(:executed) { [] }
  let(:sql_a) { "CREATE FUNCTION a() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n" }
  let(:sql_b) { "--!depends_on a\nCREATE FUNCTION b() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n" }
  let(:sql_c) { "--!depends_on b\nCREATE FUNCTION c() RETURNS integer AS $$ SELECT 1; $$ LANGUAGE sql;\n" }

  subject(:manager) do
    PgObjects::Manager.new(db_object_factory: PgObjects::DbObjectFactory.new, config:, logger:)
  end

  before do
    # Filenames ordered so the alphabetical glob yields reverse-topological order,
    # forcing dependency resolution (not file order) to drive execution.
    create_file_with('integration', '1_c.sql', sql_c)
    create_file_with('integration', '2_b.sql', sql_b)
    create_file_with('integration', '3_a.sql', sql_a)

    allow(ar).to receive(:connection) { connection }
    allow(connection).to receive(:adapter_name).and_return('PostgreSQL')
    allow(connection).to receive(:execute) { |sql| executed << sql }

    allow(config).to receive_messages(before_path: integration_path, extensions: ['sql'], silent: true)
  end

  it 'resolves real dependencies and executes objects in dependency order' do
    manager.load_files(:before).create_objects

    expect(executed).to eq([sql_a, sql_b, sql_c])
  end
end
