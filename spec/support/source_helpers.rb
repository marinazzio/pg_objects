module SourceHelpers
  def table_source(name = 'no_reason_for_this')
    <<~SQL
      CREATE TABLE #{name} (
        id INT,
        name VARCHAR(255)
      )
    SQL
  end

  def text_search_parser_source(name = 'some_text_search_parser_name')
    <<~SQL
      CREATE TEXT SEARCH PARSER #{name} (
          START = start_function ,
          GETTOKEN = gettoken_function ,
          END = end_function ,
          LEXTYPES = lextypes_function
      )
    SQL
  end

  def trigger_source(name = 'useless_trigger')
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      CREATE TRIGGER #{name} AFTER INSERT ON some_table
        EXECUTE PROCEDURE nonexistent_function();
    SQL
  end

  def function_source(name = 'some_func_name')
    <<~SQL
      CREATE FUNCTION #{name}(param INTEGER) RETURNS INTEGER AS $$
        SELECT 1;
      $$ LANGUAGE sql;
    SQL
  end

  def aggregate_source(name = 'some_agg_name')
    "CREATE AGGREGATE #{name}(jsonb) (sfunc = dont_care_about_name, stype = jsonb);"
  end

  def no_create_source
    <<~SQL
      SELECT 345;
      SELECT 456;
    SQL
  end

  def event_trigger_source(name = 'some_event_trigger_name')
    "CREATE EVENT TRIGGER #{name} ON ddl_command_start EXECUTE PROCEDURE abort_any_command();"
  end

  def materialized_view_source(name = 'some_mat_view_name')
    "CREATE MATERIALIZED VIEW #{name} AS SELECT 1, 2, 3;"
  end

  def conversion_source(name = 'some_conversion_name')
    "CREATE CONVERSION #{name} FOR 'UTF8' TO 'LATIN1' FROM myfunc;"
  end

  def view_source(name = 'some_view_name')
    "CREATE OR REPLACE VIEW #{name} AS SELECT 1, 2, 3;"
  end

  def operator_source(name = '+-*/<>=~!@#%^&|`')
    "CREATE OPERATOR #{name} (FUNCTION = omg_wtf_func);"
  end

  def operator_class_source(name = 'some_operator_class_name')
    <<~SQL
      CREATE OPERATOR CLASS #{name}
        DEFAULT FOR TYPE _int4 USING gist AS
            OPERATOR        3       &&,
            FUNCTION        1       g_int_consistent (internal, _int4, smallint, oid, internal);
    SQL
  end

  def text_search_template_source(name = 'some_text_search_tpl_name')
    "CREATE TEXT SEARCH TEMPLATE #{name} (LEXIZE = lexize_function);"
  end

  def type_source(name = 'some_type_name')
    "CREATE TYPE #{name} AS (f1 int, f2 text);"
  end
end
