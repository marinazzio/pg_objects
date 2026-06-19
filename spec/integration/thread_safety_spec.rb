RSpec.describe 'Parsing thread safety' do
  include FixtureHelpers

  let(:factory) { PgObjects::DbObjectFactory.new }
  let(:names) { (1..10).map { |i| "func_#{i}" } }
  let(:paths) { names.to_h { |name| [name, File.join(fixtures_root_path, 'integration', "#{name}.sql")] } }

  before { names.each { |name| create_object_fixture(name) } }

  it 'parses distinct SQL across threads without cross-contamination' do
    threads = names.map do |name|
      Thread.new { 50.times.map { factory.create_instance(paths[name]).object_name }.uniq }
    end

    results = threads.map(&:value)

    expect(results).to eq(names.map { |name| [name] })
  end
end
