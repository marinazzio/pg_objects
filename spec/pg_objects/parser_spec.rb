RSpec.describe PgObjects::Parser do
  using RSpec::Parameterized::TableSyntax

  subject { described_class.new.load(source) }

  let(:trigger_source) do
    <<~SQL
      --!depends_on here/is/a/path/to/object.sql
      --!depends_on some/path/to/another.sql
      CREATE TRIGGER useless_trigger AFTER INSERT ON some_table
        EXECUTE PROCEDURE nonexistent_function();
    SQL
  end

  let(:no_create_source) do
    <<~SQL
      SELECT 345;
      SELECT 456;
    SQL
  end

  let(:function_source) do
    <<~SQL
      CREATE FUNCTION some_func_name(param INTEGER) RETURNS INTEGER AS $$
        SELECT 1;
      $$ LANGUAGE sql;
    SQL
  end

  let(:aggregate_source) { 'CREATE AGGREGATE some_agg_name(jsonb) (sfunc = dont_care_about_name, stype = jsonb);' }
  let(:event_trigger_source) { 'CREATE EVENT TRIGGER some_event_trigger_name ON ddl_command_start EXECUTE PROCEDURE abort_any_command();' }
  let(:mat_view_source) { 'CREATE MATERIALIZED VIEW some_mat_view_name AS SELECT 1, 2, 3;' }
  let(:conversion_source) { "CREATE CONVERSION some_conversion_name FOR 'UTF8' TO 'LATIN1' FROM myfunc;" }
  let(:view_source) { 'CREATE OR REPLACE VIEW some_view_name AS SELECT 1, 2, 3;' }
  let(:operator_source) { 'CREATE OPERATOR +-*/<>=~!@#%^&|` (FUNCTION = omg_wtf_func);' }
  let(:operator_class_source) do
    <<~SQL
      CREATE OPERATOR CLASS some_operator_class_name
        DEFAULT FOR TYPE _int4 USING gist AS
            OPERATOR        3       &&,
            FUNCTION        1       g_int_consistent (internal, _int4, smallint, oid, internal);
    SQL
  end

  let(:text_search_parser_source) do
    <<~SQL
      CREATE TEXT SEARCH PARSER some_text_search_parser_name (
          START = start_function ,
          GETTOKEN = gettoken_function ,
          END = end_function ,
          LEXTYPES = lextypes_function
      )
    SQL
  end
  let(:text_search_tpl_source) { 'CREATE TEXT SEARCH TEMPLATE some_text_search_tpl_name (LEXIZE = lexize_function);' }
  let(:type_source) { 'CREATE TYPE some_type_name AS (f1 int, f2 text);' }

  context 'with depends_on directives' do
    let(:source) { trigger_source }
    let(:fetched_deps) { ['here/is/a/path/to/object.sql', 'some/path/to/another.sql'] }

    it 'fetches depends_on directives' do
      dirs = subject.fetch_directives
      expect(dirs[:depends_on].sort).to eq(fetched_deps.sort)
    end
  end

  context 'with no create query' do
    let(:source) { no_create_source }

    it 'fetches nil as object_name when it is impossible' do
      expect(subject.fetch_object_name).to be_nil
    end
  end

  context 'with create object query' do
    where(:source, :expected_name) do
      trigger_source            | 'useless_trigger'
      function_source           | 'some_func_name'
      aggregate_source          | 'some_agg_name'
      conversion_source         | 'some_conversion_name'
      event_trigger_source      | 'some_event_trigger_name'
      mat_view_source           | 'some_mat_view_name'
      operator_source           | '+-*/<>=~!@#%^&|`'
      operator_class_source     | 'some_operator_class_name'
      text_search_parser_source | 'some_text_search_parser_name'
      text_search_tpl_source    | 'some_text_search_tpl_name'
      type_source               | 'some_type_name'
      view_source               | 'some_view_name'
    end

    with_them do
      it "returns object name: #{params[:expected_name]}" do
        expect(subject.fetch_object_name).to eq(expected_name)
      end
    end
  end
end
