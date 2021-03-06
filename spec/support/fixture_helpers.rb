require 'fileutils'

module FixtureHelpers
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def create_fixtures(event)
    event = event.to_s
    create_file_with File.join(event, 'trash'), 'some_shitty_file', 'just want to be here'
    create_file_with File.join(event, 'functions/1'), 'simple_function.sql', 'SELECT 1;'
    create_file_with File.join(event, 'functions/2'), 'simple_function.sql', 'SELECT 1;'
    create_file_with File.join(event, 'functions/2'), 'uniquely_named_function.sql', <<~SQL
      CREATE OR REPLACE FUNCTION my_function(p_param VARCHAR) RETURNS INTEGER AS $$
      BEGIN SELECT 123; END
      $$ LANGUAGE plpgsql;
    SQL
    create_file_with File.join(event, 'triggers/1'), 'simple_trigger.sql', 'SELECT 1;'
    create_file_with File.join(event, 'triggers/2'), 'dependent_trigger.sql', <<~SQL
      --!depends_on uniquely_named_function
      SELECT 1;
    SQL
    create_file_with File.join(event, 'triggers/2'), 'ambiguous_trigger.sql_amb', <<~SQL
      --!depends_on simple_function
      SELECT 1;
    SQL
    create_file_with File.join(event, 'triggers/2'), 'cyclic_dependence.sql_clc', <<~SQL
      --!depends_on cyclic_dependence
      SELECT 1;
    SQL
    create_file_with File.join(event, 'triggers/3'), 'nonexist_dependent_trigger.sql_dne', <<~SQL
      --!depends_on   sdlkfjwelkrj
      SELECT 1;
    SQL
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def clean_fixtures
    FileUtils.rmtree fixtures_root_path
    FileUtils.mkpath fixtures_root_path
  end

  def fixtures_list(event, extension)
    Dir[File.join(fixtures_root_path, event.to_s, '**', "*.#{extension}")]
  end

  private

  def fixtures_root_path
    File.expand_path 'spec/fixtures/objects'
  end

  def create_file_with(sub_path, name, content)
    dir_path = File.join(fixtures_root_path, sub_path)
    FileUtils.mkpath dir_path
    File.open [dir_path, name].join('/'), 'w' do |file|
      file << content
    end
  end
end
