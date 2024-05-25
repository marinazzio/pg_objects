RSpec.describe PgObjects::ParsedObjectFactory do
  include SourceHelpers

  using RSpec::Parameterized::TableSyntax

  subject { described_class.create_object(parsed_query) }

  let(:parsed_query) { PgQuery.parse(source) }

  context 'with different kinds of sources' do
    where(:source, :expected_class) do
      trigger_source            | PgObjects::ParsedObject::Trigger
      function_source           | PgObjects::ParsedObject::Function
      aggregate_source          | PgObjects::ParsedObject::Aggregate
      conversion_source         | PgObjects::ParsedObject::Conversion
      event_trigger_source      | PgObjects::ParsedObject::EventTrigger
      mat_view_source           | PgObjects::ParsedObject::MaterializedView
      operator_source           | PgObjects::ParsedObject::Operator
      operator_class_source     | PgObjects::ParsedObject::OperatorClass
      text_search_parser_source | PgObjects::ParsedObject::TextSearchParser
      text_search_tpl_source    | PgObjects::ParsedObject::TextSearchTemplate
      type_source               | PgObjects::ParsedObject::Type
      view_source               | PgObjects::ParsedObject::View
    end

    with_them do
      it "returns #{expected_class} object" do
        expect(subject).to be_an_instance_of(expected_class)
      end
    end
  end
end
