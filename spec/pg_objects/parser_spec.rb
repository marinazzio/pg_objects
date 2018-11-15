RSpec.describe PgObjects::Parser do
  let(:sql1_body) do
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      CREATE TRIGGER useless_trigger AFTER INSERT ON some_table
        EXECUTE PROCEDURE nonexistent_function();
    SQL
  end

  let(:sql2_body) do
    <<~SQL
      SELECT 345;
      SELECT 456;
    SQL
  end

  let(:func_sql) do
    <<~SQL
      CREATE FUNCTION some_func_name(param INTEGER) RETURNS INTEGER AS $$
        SELECT 1;
      $$ LANGUAGE sql;
    SQL
  end

  let(:aggregate_sql) { 'CREATE AGGREGATE some_agg_name(jsonb) (sfunc = dont_care_about_name, stype = jsonb);' }
  let(:event_trigger_sql) { 'CREATE EVENT TRIGGER some_event_trigger_name ON ddl_command_start EXECUTE PROCEDURE abort_any_command();' }
  let(:mat_view_sql) { 'CREATE MATERIALIZED VIEW some_mat_view_name AS SELECT 1, 2, 3;' }
  let(:conversion_sql) { "CREATE CONVERSION some_conversion_name FOR 'UTF8' TO 'LATIN1' FROM myfunc;" }
  let(:view_sql) { 'CREATE OR REPLACE VIEW some_view_name AS SELECT 1, 2, 3;' }
  let(:operator_sql) { 'CREATE OPERATOR +-*/<>=~!@#%^&|` (FUNCTION = omg_wtf_func);' }
  let(:operator_class_sql) do
    <<~SQL
      CREATE OPERATOR CLASS some_operator_class_name
        DEFAULT FOR TYPE _int4 USING gist AS
            OPERATOR        3       &&,
            FUNCTION        1       g_int_consistent (internal, _int4, smallint, oid, internal);
    SQL
  end

  let(:text_search_parser_sql) do
    <<~SQL
      CREATE TEXT SEARCH PARSER some_text_search_parser_name (
          START = start_function ,
          GETTOKEN = gettoken_function ,
          END = end_function ,
          LEXTYPES = lextypes_function
      )
    SQL
  end
  let(:text_search_tpl_sql) { 'CREATE TEXT SEARCH TEMPLATE some_text_search_tpl_name (LEXIZE = lexize_function);' }
  let(:type_sql) { 'CREATE TYPE some_type_name AS (f1 int, f2 text);' }

  let(:fetched_deps) { ['here/is/a/path/to/object.sql', 'some/path/to/another.sql'] }

  it 'fetches depends_on directives' do
    dirs = described_class.fetch_directives(sql1_body)
    expect(dirs[:depends_on].sort).to eq(fetched_deps.sort)
  end

  it 'fetches nil as object_name when it is impossible' do
    expect(described_class.fetch_object_name(sql2_body)).to be_nil
  end

  context 'with object_name' do
    it 'fetches for trigger' do
      expect(described_class.fetch_object_name(sql1_body)).to eq('useless_trigger')
    end

    it 'fetches for function' do
      expect(described_class.fetch_object_name(func_sql)).to eq('some_func_name')
    end

    it 'fetches for aggregate' do
      expect(described_class.fetch_object_name(aggregate_sql)).to eq('some_agg_name')
    end

    it 'fetches for conversion' do
      expect(described_class.fetch_object_name(conversion_sql)).to eq('some_conversion_name')
    end

    it 'fetches for event trigger' do
      expect(described_class.fetch_object_name(event_trigger_sql)).to eq('some_event_trigger_name')
    end

    it 'fetches for materialized view' do
      expect(described_class.fetch_object_name(mat_view_sql)).to eq('some_mat_view_name')
    end

    it 'fetches for operator' do
      expect(described_class.fetch_object_name(operator_sql)).to eq('+-*/<>=~!@#%^&|`')
    end

    it 'fetches for operator class' do
      expect(described_class.fetch_object_name(operator_class_sql)).to eq('some_operator_class_name')
    end

    it 'fetches for text search parser' do
      expect(described_class.fetch_object_name(text_search_parser_sql)).to eq('some_text_search_parser_name')
    end

    it 'fetches for text search template' do
      expect(described_class.fetch_object_name(text_search_tpl_sql)).to eq('some_text_search_tpl_name')
    end

    it 'fetches for type' do
      expect(described_class.fetch_object_name(type_sql)).to eq('some_type_name')
    end

    it 'fetches for view' do
      expect(described_class.fetch_object_name(view_sql)).to eq('some_view_name')
    end
  end
end
