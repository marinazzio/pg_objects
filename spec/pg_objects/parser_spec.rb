RSpec.describe PgObjects::Parser do
  include SourceHelpers

  using RSpec::Parameterized::TableSyntax

  subject { described_class.new.load(source) }

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
