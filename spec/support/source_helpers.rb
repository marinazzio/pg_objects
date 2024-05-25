module SourceHelpers
  def text_search_parser_source
    <<~SQL
      CREATE TEXT SEARCH PARSER some_text_search_parser_name (
          START = start_function ,
          GETTOKEN = gettoken_function ,
          END = end_function ,
          LEXTYPES = lextypes_function
      )
    SQL
  end

  def trigger_source
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      CREATE TRIGGER useless_trigger AFTER INSERT ON some_table
        EXECUTE PROCEDURE nonexistent_function();
    SQL
  end

  def function_source
    <<~SQL
      CREATE FUNCTION some_func_name(param INTEGER) RETURNS INTEGER AS $$
        SELECT 1;
      $$ LANGUAGE sql;
    SQL
  end

  def aggregate_source
    'CREATE AGGREGATE some_agg_name(jsonb) (sfunc = dont_care_about_name, stype = jsonb);'
  end

  def no_create_source
    <<~SQL
      SELECT 345;
      SELECT 456;
    SQL
  end

  def event_trigger_source
    'CREATE EVENT TRIGGER some_event_trigger_name ON ddl_command_start EXECUTE PROCEDURE abort_any_command();'
  end

  def mat_view_source
    'CREATE MATERIALIZED VIEW some_mat_view_name AS SELECT 1, 2, 3;'
  end

  def conversion_source
    "CREATE CONVERSION some_conversion_name FOR 'UTF8' TO 'LATIN1' FROM myfunc;"
  end

  def view_source
    'CREATE OR REPLACE VIEW some_view_name AS SELECT 1, 2, 3;'
  end

  def operator_source
    'CREATE OPERATOR +-*/<>=~!@#%^&|` (FUNCTION = omg_wtf_func);'
  end

  def operator_class_source
    <<~SQL
      CREATE OPERATOR CLASS some_operator_class_name
        DEFAULT FOR TYPE _int4 USING gist AS
            OPERATOR        3       &&,
            FUNCTION        1       g_int_consistent (internal, _int4, smallint, oid, internal);
    SQL
  end

  def text_search_tpl_source
    'CREATE TEXT SEARCH TEMPLATE some_text_search_tpl_name (LEXIZE = lexize_function);'
  end

  def type_source
    'CREATE TYPE some_type_name AS (f1 int, f2 text);'
  end
end
