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

  context 'when reused across load calls' do
    let(:parser) { described_class.new }

    it 'returns object_name from the most recently loaded source' do
      parser.load(function_source('first_func')).fetch_object_name

      expect(parser.load(function_source('second_func')).fetch_object_name).to eq('second_func')
    end

    it 'returns directives from the most recently loaded source' do
      parser.load("--!depends_on dep_a\nSELECT 1;").fetch_directives

      expect(parser.load("--!depends_on dep_b\nSELECT 1;").fetch_directives[:depends_on]).to eq(['dep_b'])
    end
  end

  context 'with a supported create query' do
    let(:source) { function_source }

    it 'fetches the parsed object name' do
      expect(subject.fetch_object_name).to eq('some_func_name')
    end
  end

  context 'with no create query' do
    let(:source) { no_create_source }

    it 'fetches nil as object_name when it is impossible' do
      expect(subject.fetch_object_name).to be_nil
    end

    it 'reaches nil through the controlled UnknownObjectTypeError path' do
      expect { PgObjects::ParsedObjectFactory.create_object(PgQuery.parse(source)) }
        .to raise_error(PgObjects::UnknownObjectTypeError)
    end
  end

  context 'with invalid SQL syntax' do
    let(:source) { 'THIS IS NOT VALID SQL ;;;' }

    it 'fetches nil as object_name via the rescued ParseError' do
      expect(subject.fetch_object_name).to be_nil
    end
  end

  context 'when a NoMethodError occurs while resolving the object' do
    subject(:parser) { described_class.new(parsed_object_factory: factory).load(table_source) }

    let(:factory) { class_double(PgObjects::ParsedObjectFactory) }

    before { allow(factory).to receive(:create_object).and_raise(NoMethodError, 'undefined method') }

    it 'no longer swallows the NoMethodError' do
      expect { parser.fetch_object_name }.to raise_error(NoMethodError, 'undefined method')
    end
  end

  describe 'depends_on edge cases' do
    subject(:deps) { described_class.new.load(source).fetch_directives[:depends_on] }

    context 'with a --! prefixed directive' do
      let(:source) { "--!depends_on foo\nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with a #! prefixed directive' do
      let(:source) { "#!depends_on foo\nSELECT 1;" }

      it 'parses the #! prefix' do
        expect(deps).to eq(['foo'])
      end
    end

    context 'with extra spaces around the dependency name' do
      let(:source) { "--!depends_on     foo\nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with a tab between the directive and the dependency' do
      let(:source) { "--!depends_on\tfoo\nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with trailing whitespace after the dependency' do
      let(:source) { "--!depends_on foo   \nSELECT 1;" }

      it { should eq(['foo']) }
    end

    context 'with a leading-indented directive' do
      let(:source) { "   --!depends_on foo\nSELECT 1;" }

      it 'is not parsed because the prefix must start the line' do
        expect(deps).to eq([])
      end
    end

    context 'with a directive in the middle of the file' do
      let(:source) { "SELECT 1;\n--!depends_on foo\nSELECT 2;" }

      it 'parses directives located anywhere in the file' do
        expect(deps).to eq(['foo'])
      end
    end

    context 'with a header-only directive' do
      let(:source) { "--!depends_on foo\nSELECT 1;\nSELECT 2;" }

      it { should eq(['foo']) }
    end

    context 'with no directives' do
      let(:source) { "SELECT 1;\nSELECT 2;" }

      it 'returns an empty array' do
        expect(deps).to eq([])
      end
    end

    context 'with multiple distinct dependencies' do
      let(:source) { "--!depends_on foo\n--!depends_on bar\nSELECT 1;" }

      it { should eq(%w[foo bar]) }
    end

    context 'with duplicate dependencies' do
      let(:source) { "--!depends_on foo\n--!depends_on foo\nSELECT 1;" }

      it 'preserves duplicates' do
        expect(deps).to eq(%w[foo foo])
      end
    end

    context 'with an unknown directive' do
      let(:source) { "--!something_else whatever\nSELECT 1;" }

      it 'is ignored' do
        expect(deps).to eq([])
      end
    end

    context 'with a depends_on directive that has no dependency name' do
      let(:source) { "--!depends_on\nSELECT 1;" }

      it 'is ignored' do
        expect(deps).to eq([])
      end
    end
  end
end
