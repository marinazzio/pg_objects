RSpec.shared_context 'with parsed object context' do
  include SourceHelpers

  subject { described_class.new(stmt) }

  let(:object_name) { Faker::Internet.slug(glue: '_') }
  let(:source_helper) { "#{described_class.to_s.demodulize.underscore}_source" }
  let(:stmt) { PgQuery.parse(send(source_helper, object_name)).tree.stmts[0].stmt }
end
