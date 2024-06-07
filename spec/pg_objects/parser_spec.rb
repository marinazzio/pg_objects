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
end
