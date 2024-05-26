RSpec.describe PgObjects::ParsedObjectFactory do
  include SourceHelpers

  using RSpec::Parameterized::TableSyntax

  subject { described_class.create_object(parsed_query) }

  let(:parsed_query) { PgQuery.parse(source) }

  context 'with different kinds of sources' do
    where(:source, :expected_class) do
      aggregate_source          | PgObjects::ParsedObject::Aggregate
      conversion_source         | PgObjects::ParsedObject::Conversion
      event_trigger_source      | PgObjects::ParsedObject::EventTrigger
      function_source           | PgObjects::ParsedObject::Function
      mat_view_source           | PgObjects::ParsedObject::MaterializedView
      operator_class_source     | PgObjects::ParsedObject::OperatorClass
      operator_source           | PgObjects::ParsedObject::Operator
      table_source              | PgObjects::ParsedObject::Table
      text_search_parser_source | PgObjects::ParsedObject::TextSearchParser
      text_search_tpl_source    | PgObjects::ParsedObject::TextSearchTemplate
      trigger_source            | PgObjects::ParsedObject::Trigger
      type_source               | PgObjects::ParsedObject::Type
      view_source               | PgObjects::ParsedObject::View
    end

    with_them do
      it "returns #{params[:expected_class]} object" do
        expect(subject).to be_an_instance_of(expected_class)
      end
    end
  end
end
