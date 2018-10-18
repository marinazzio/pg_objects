module FixtureHelpers
  # rubocop:disable Metrics/MethodLength
  def create_fixtures
    create_file_with 'trash', 'some_shitty_file', 'just want to be here'
    create_file_with 'functions/1', 'simple_function.sql', 'SELECT 1;'
    create_file_with 'functions/2', 'simple_function.sql', 'SELECT 1;'
    create_file_with 'functions/2', 'uniquely_named_function.sql', 'SELECT 1;'
    create_file_with 'triggers/1', 'simple_trigger.sql', 'SELECT 1;'
    create_file_with 'triggers/2', 'dependent_trigger.sql', <<~SQL
      --!depends_on uniquely_named_function
      SELECT 1;
    SQL
    create_file_with 'triggers/2', 'ambiguous_trigger.sql_amb', <<~SQL
      --!depends_on simple_function
      SELECT 1;
    SQL
    create_file_with 'triggers/2', 'cyclic_dependence.sql_clc', <<~SQL
      --!depends_on cyclic_dependence
      SELECT 1;
    SQL
    create_file_with 'triggers/3', 'nonexist_dependent_trigger.sql_dne', <<~SQL
      --!depends_on   sdlkfjwelkrj
      SELECT 1;
    SQL
  end
  # rubocop:enable Metrics/MethodLength

  def clean_fixtures
    FileUtils.rmtree fixtures_root_path
    FileUtils.mkpath fixtures_root_path
  end

  def fixtures_list(extension)
    Dir[File.join(fixtures_root_path, '**', "*.#{extension}")]
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
