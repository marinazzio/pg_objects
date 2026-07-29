require 'rails/railtie'
require 'rake'
require 'pg_objects/railtie'

RSpec.describe PgObjects::Railtie do
  it 'is a Rails::Railtie' do
    expect(described_class.superclass).to eq(Rails::Railtie)
  end

  describe 'rake task registration' do
    around do |example|
      original_application = Rake.application
      example.run
    ensure
      Rake.application = original_application
    end

    before do
      Rake.application = Rake::Application.new
      allow(PgObjects::Config.config).to receive(:auto_hook_migrations).and_return(false)
      described_class.instance.send(:run_tasks_blocks, Rake.application)
    end

    it 'defines the db:create_objects:before task' do
      expect(Rake::Task.task_defined?('db:create_objects:before')).to be(true)
    end

    it 'defines the db:create_objects:after task' do
      expect(Rake::Task.task_defined?('db:create_objects:after')).to be(true)
    end
  end

  describe 'conditional loading on the Rails constant' do
    let(:lib_dir) { File.expand_path('../../lib', __dir__) }
    let(:probe) { 'print defined?(PgObjects::Railtie).inspect' }

    it 'is not loaded when Rails is undefined' do
      output = IO.popen(
        [RbConfig.ruby, '-rbundler/setup', "-I#{lib_dir}", '-e', "require 'pg_objects'; #{probe}"], &:read
      )

      expect(output).to eq('nil')
    end

    it 'is loaded when Rails is defined' do
      output = IO.popen(
        [RbConfig.ruby, '-rbundler/setup', "-I#{lib_dir}", '-e',
         "require 'active_support'; require 'rails/railtie'; require 'pg_objects'; #{probe}"], &:read
      )

      expect(output).to eq('"constant"')
    end
  end
end
