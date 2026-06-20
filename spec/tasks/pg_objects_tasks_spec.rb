require 'rake'

RSpec.describe 'pg_objects rake hooks' do # rubocop:disable RSpec/DescribeClass
  let(:rake_file) { File.expand_path('../../lib/tasks/pg_objects_tasks.rake', __dir__) }
  let(:manager) { instance_double(PgObjects::Manager) }
  let(:auto_hook_migrations) { true }

  around do |example|
    original_application = Rake.application
    example.run
  ensure
    Rake.application = original_application
  end

  before do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    %w[db:migrate db:schema:load db:migrate:redo db:rollback].each { |name| Rake::Task.define_task(name) }

    allow(PgObjects::Config.config).to receive(:auto_hook_migrations).and_return(auto_hook_migrations)
    load rake_file

    allow(PgObjects::Manager).to receive(:new).and_return(manager)
    allow(manager).to receive_messages(load_files: manager, create_objects: manager)
  end

  it 'runs both before and after object creation around db:migrate', :aggregate_failures do
    Rake::Task['db:migrate'].invoke

    expect(manager).to have_received(:load_files).with(:before)
    expect(manager).to have_received(:load_files).with(:after)
  end

  it 'runs only after object creation for db:schema:load', :aggregate_failures do
    Rake::Task['db:schema:load'].invoke

    expect(manager).to have_received(:load_files).with(:after)
    expect(manager).not_to have_received(:load_files).with(:before)
  end

  it 'runs both before and after object creation around db:migrate:redo', :aggregate_failures do
    Rake::Task['db:migrate:redo'].invoke

    expect(manager).to have_received(:load_files).with(:before)
    expect(manager).to have_received(:load_files).with(:after)
  end

  it 'does not hook db:rollback' do
    Rake::Task['db:rollback'].invoke

    expect(manager).not_to have_received(:load_files)
  end

  context 'when auto_hook_migrations is false' do
    let(:auto_hook_migrations) { false }

    it 'installs no hooks, leaving object creation to be invoked manually' do
      Rake::Task['db:migrate'].invoke

      expect(manager).not_to have_received(:load_files)
    end

    it 'still exposes the manual db:create_objects tasks' do
      Rake::Task['db:create_objects:before'].invoke

      expect(manager).to have_received(:load_files).with(:before)
    end
  end
end
