require 'spec_helper'
require 'fileutils'
require 'tempfile'

RSpec.describe 'PgObjects integration with dummy Rails app', type: :integration do
  let(:dummy_app_path) { File.expand_path('../../../test/integration/dummy_app', __FILE__) }

  before(:all) do
    # Ensure dummy app exists
    @dummy_app_path = File.expand_path('../../../test/integration/dummy_app', __FILE__)
    expect(File.exist?(@dummy_app_path)).to be true
    expect(File.exist?(File.join(@dummy_app_path, 'Gemfile'))).to be true
  end

  describe 'generator installation' do
    it 'creates the required directory structure' do
      expect(Dir.exist?(File.join(dummy_app_path, 'db/objects'))).to be true
      expect(Dir.exist?(File.join(dummy_app_path, 'db/objects/before'))).to be true
      expect(Dir.exist?(File.join(dummy_app_path, 'db/objects/after'))).to be true
    end
  end

  describe 'SQL object management' do
    let(:before_dir) { File.join(dummy_app_path, 'db/objects/before') }
    let(:after_dir) { File.join(dummy_app_path, 'db/objects/after') }

    before do
      # Clean up any existing SQL files
      Dir[File.join(before_dir, '*.sql')].each { |f| File.delete(f) }
      Dir[File.join(after_dir, '*.sql')].each { |f| File.delete(f) }
    end

    after do
      # Clean up any created SQL files
      Dir[File.join(before_dir, '*.sql')].each { |f| File.delete(f) }
      Dir[File.join(after_dir, '*.sql')].each { |f| File.delete(f) }
    end

    it 'loads and creates SQL objects without dependencies' do
      # Create a simple function
      function_sql = <<~SQL
        CREATE OR REPLACE FUNCTION test_function()
        RETURNS INTEGER AS $$
        BEGIN
          RETURN 42;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      File.write(File.join(before_dir, 'test_function.sql'), function_sql)

      # Test that the file loading works without database connection errors
      # We need to configure the manager to use the correct path
      PgObjects.configure do |config|
        config.before_path = before_dir
      end

      # Test that the file loading works without database connection errors
      # We can't actually test database execution without a real database
      # but we can test the parsing and object management logic
      manager = PgObjects::Manager.new
      
      # Mock the database connection check to avoid PostgreSQL adapter requirement
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :adapter_name).and_return('PostgreSQL')
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :execute)

      expect { manager.load_files(:before) }.not_to raise_error
      expect(manager.objects.length).to eq(1)
      expect(manager.objects.first.name).to eq('test_function')
      
      # Reset config
      PgObjects.configure { |config| config.before_path = 'db/objects/before' }
    end

    it 'handles dependencies correctly' do
      # Create two functions with dependency
      base_function = <<~SQL
        CREATE OR REPLACE FUNCTION base_function()
        RETURNS INTEGER AS $$
        BEGIN
          RETURN 1;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      dependent_function = <<~SQL
        --!depends_on base_function
        CREATE OR REPLACE FUNCTION dependent_function()
        RETURNS INTEGER AS $$
        BEGIN
          RETURN base_function() + 1;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      File.write(File.join(before_dir, 'base_function.sql'), base_function)
      File.write(File.join(before_dir, 'dependent_function.sql'), dependent_function)

      # Configure the manager to use the correct path
      PgObjects.configure do |config|
        config.before_path = before_dir
      end

      manager = PgObjects::Manager.new
      
      # Mock the database connection
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :adapter_name).and_return('PostgreSQL')
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :execute)

      expect { manager.load_files(:before) }.not_to raise_error
      expect(manager.objects.length).to eq(2)
      
      dependent_obj = manager.objects.find { |obj| obj.name == 'dependent_function' }
      expect(dependent_obj.dependencies).to include('base_function')
      
      # Reset config
      PgObjects.configure { |config| config.before_path = 'db/objects/before' }
    end

    it 'raises error for missing dependencies' do
      # Create function with non-existent dependency
      function_with_missing_dep = <<~SQL
        --!depends_on non_existent_function
        CREATE OR REPLACE FUNCTION test_function()
        RETURNS INTEGER AS $$
        BEGIN
          RETURN 42;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      File.write(File.join(before_dir, 'test_function.sql'), function_with_missing_dep)

      # Configure the manager to use the correct path
      PgObjects.configure do |config|
        config.before_path = before_dir
      end

      manager = PgObjects::Manager.new
      
      # Mock the database connection
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :adapter_name).and_return('PostgreSQL')

      manager.load_files(:before)
      
      expect { manager.create_objects }.to raise_error(PgObjects::DependencyNotExistError)
      
      # Reset config
      PgObjects.configure { |config| config.before_path = 'db/objects/before' }
    end

    it 'raises error for cyclic dependencies' do
      # Create two functions with cyclic dependency
      function_a = <<~SQL
        --!depends_on function_b
        CREATE OR REPLACE FUNCTION function_a()
        RETURNS INTEGER AS $$
        BEGIN
          RETURN 1;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      function_b = <<~SQL
        --!depends_on function_a
        CREATE OR REPLACE FUNCTION function_b()
        RETURNS INTEGER AS $$
        BEGIN
          RETURN 2;
        END;
        $$ LANGUAGE plpgsql;
      SQL

      File.write(File.join(before_dir, 'function_a.sql'), function_a)
      File.write(File.join(before_dir, 'function_b.sql'), function_b)

      # Configure the manager to use the correct path
      PgObjects.configure do |config|
        config.before_path = before_dir
      end

      manager = PgObjects::Manager.new
      
      # Mock the database connection
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :adapter_name).and_return('PostgreSQL')

      manager.load_files(:before)
      
      expect { manager.create_objects }.to raise_error(PgObjects::CyclicDependencyError)
      
      # Reset config
      PgObjects.configure { |config| config.before_path = 'db/objects/before' }
    end
  end

  describe 'configuration' do
    it 'uses custom configuration paths' do
      # Test that custom paths work
      PgObjects.configure do |config|
        config.before_path = 'custom/before'
        config.after_path = 'custom/after'
        config.extensions = ['sql', 'txt']
      end

      expect(PgObjects.config.before_path).to eq('custom/before')
      expect(PgObjects.config.after_path).to eq('custom/after')
      expect(PgObjects.config.extensions).to eq(['sql', 'txt'])

      # Reset to defaults
      PgObjects.configure do |config|
        config.before_path = 'db/objects/before'
        config.after_path = 'db/objects/after'
        config.extensions = ['sql']
      end
    end

    it 'handles silent mode correctly' do
      # Test silent mode through the configuration
      original_silent = PgObjects.config.silent

      # Test default behavior (not silent)
      PgObjects.configure { |config| config.silent = false }
      logger = PgObjects::Logger.new
      expect { logger.write('test message') }.to output(/test message/).to_stdout

      # Test silent mode
      PgObjects.configure { |config| config.silent = true }
      logger = PgObjects::Logger.new
      expect { logger.write('test message') }.not_to output.to_stdout

      # Reset to original value
      PgObjects.configure { |config| config.silent = original_silent }
    end
  end

  describe 'error handling' do
    it 'raises error for unsupported database adapter' do
      manager = PgObjects::Manager.new
      
      # Mock non-PostgreSQL adapter
      allow(ActiveRecord::Base).to receive_message_chain(:connection, :adapter_name).and_return('MySQL')

      expect { manager.load_files(:before) }.to raise_error(PgObjects::UnsupportedAdapterError)
    end
  end

  describe 'object types parsing' do
    let(:before_dir) { File.join(dummy_app_path, 'db/objects/before') }

    before do
      Dir[File.join(before_dir, '*.sql')].each { |f| File.delete(f) }
    end

    after do
      Dir[File.join(before_dir, '*.sql')].each { |f| File.delete(f) }
    end

    it 'correctly identifies different SQL object types' do
      # Test various object types
      test_cases = [
        {
          name: 'test_function',
          sql: 'CREATE FUNCTION test_function() RETURNS INTEGER AS $$ SELECT 1; $$ LANGUAGE sql;',
          expected_type: PgObjects::ParsedObject::Function
        },
        {
          name: 'test_view',
          sql: 'CREATE VIEW test_view AS SELECT 1, 2, 3;',
          expected_type: PgObjects::ParsedObject::View
        },
        {
          name: 'test_trigger',
          sql: 'CREATE TRIGGER test_trigger AFTER INSERT ON some_table EXECUTE PROCEDURE some_function();',
          expected_type: PgObjects::ParsedObject::Trigger
        }
      ]

      # Configure the manager to use the correct path
      PgObjects.configure do |config|
        config.before_path = before_dir
      end

      test_cases.each do |test_case|
        File.write(File.join(before_dir, "#{test_case[:name]}.sql"), test_case[:sql])

        manager = PgObjects::Manager.new
        
        # Mock the database connection
        allow(ActiveRecord::Base).to receive_message_chain(:connection, :adapter_name).and_return('PostgreSQL')

        manager.load_files(:before)
        obj = manager.objects.find { |o| o.name == test_case[:name] }
        
        expect(obj).not_to be_nil
        obj.create # This triggers parsing
        parsed_obj = obj.instance_variable_get(:@parser).send(:parsed_object)
        expect(parsed_obj).to be_a(test_case[:expected_type])
        
        # Clean up for next iteration
        File.delete(File.join(before_dir, "#{test_case[:name]}.sql"))
        manager.objects.clear
      end
      
      # Reset config
      PgObjects.configure { |config| config.before_path = 'db/objects/before' }
    end
  end

  describe 'Rake task integration' do
    it 'has the expected rake tasks available in Rails environment' do
      # Check that the rake tasks are loaded
      rake_tasks = [
        'db:create_objects:before',
        'db:create_objects:after'
      ]
      
      # We can't actually run the rake tasks without a real database,
      # but we can verify the task definitions exist by checking the railtie
      railtie_path = File.expand_path('../../../lib/pg_objects/railtie.rb', __FILE__)
      expect(File.exist?(railtie_path)).to be true
      
      # Check that the tasks are defined
      task_file_path = File.expand_path('../../../lib/tasks/pg_objects_tasks.rake', __FILE__)
      expect(File.exist?(task_file_path)).to be true
      
      # Verify the task file contains our expected task definitions
      task_content = File.read(task_file_path)
      expect(task_content).to include('db:create_objects:before')
      expect(task_content).to include('db:create_objects:after')
      expect(task_content).to include("before 'db:migrate'")
      expect(task_content).to include("after 'db:migrate'")
    end
  end
end