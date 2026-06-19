RSpec.describe PgObjects::ParsedObjectFactory do
  using RSpec::Parameterized::TableSyntax

  subject { described_class.create_object(parsed_query) }

  let(:parsed_query) { PgQuery.parse(source) }

  context 'with different kinds of sources' do
    where(:source, :expected_class) do
      aggregate_source            | PgObjects::ParsedObject::Aggregate
      conversion_source           | PgObjects::ParsedObject::Conversion
      event_trigger_source        | PgObjects::ParsedObject::EventTrigger
      function_source             | PgObjects::ParsedObject::Function
      materialized_view_source    | PgObjects::ParsedObject::MaterializedView
      operator_class_source       | PgObjects::ParsedObject::OperatorClass
      operator_source             | PgObjects::ParsedObject::Operator
      table_source                | PgObjects::ParsedObject::Table
      text_search_parser_source   | PgObjects::ParsedObject::TextSearchParser
      text_search_template_source | PgObjects::ParsedObject::TextSearchTemplate
      trigger_source              | PgObjects::ParsedObject::Trigger
      type_source                 | PgObjects::ParsedObject::Type
      view_source                 | PgObjects::ParsedObject::View
    end

    with_them do
      it "returns #{params[:expected_class]} object" do
        expect(subject).to be_an_instance_of(expected_class)
      end
    end
  end

  context 'with an unsupported statement type' do
    where(:source, :stmt_type) do
      no_create_source     | 'select_stmt'
      'CREATE SCHEMA foo;' | 'create_schema_stmt'
      'CREATE ROLE bar;'   | 'create_role_stmt'
    end

    with_them do
      it 'raises UnknownObjectTypeError identifying the statement type' do
        expect { subject }.to raise_error(PgObjects::UnknownObjectTypeError, "unknown object type: #{stmt_type}")
      end
    end
  end

  context 'with thread safety' do
    let(:table_query) { PgQuery.parse(table_source) }
    let(:function_query) { PgQuery.parse(function_source) }

    it 'creates the correct class for each concurrently parsed query without stomping shared state' do
      threads = [
        Thread.new { 100.times.map { described_class.create_object(table_query) }.last },
        Thread.new { 100.times.map { described_class.create_object(function_query) }.last }
      ]

      expect(threads.map(&:value)).to contain_exactly(
        an_instance_of(PgObjects::ParsedObject::Table),
        an_instance_of(PgObjects::ParsedObject::Function)
      )
    end
  end
end
